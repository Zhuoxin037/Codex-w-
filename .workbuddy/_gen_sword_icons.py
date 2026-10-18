# -*- coding: utf-8 -*-
"""_gen_sword_icons.py —— 生成「剑类平面图标」的数据包侧驱动（唯一真相来源）

【为什么要有这个文件】
  13 件剑（12 件平面图标 + 火种两态）在资源包 `sweetdream_rp_原版风` 里已经有 items
  定义，但**光有资源包没用** —— 物品身上必须有人把 `item_model` 组件写成
  `sweetdream:<id>`，客户端才会去用那份定义。这个脚本就是生成"写组件的那只手"。

【产出三样东西】
  ① item_modifier/sword_icons/<id>.json —— 给一件剑写上自己的 item_model
  ② function/visual/sword_icon_held.mcfunction —— 手持扫描，把**还没改过的**补上
  ③ function/visual/sword_icon_sync.mcfunction —— 每秒入口（挂 event/second）
  ＋ 幂等登记 `sweetdream:visual/sword_icon_sync` 到
     data/manacore/tags/function/event/second.json

【★ 为什么不写在 give 里就完事】
  give 只覆盖"以后新给的"。玩家背包里**已经发出去**的那批剑没有 item_model，
  只会在游戏里显示成原版铁剑/钻石剑。②③ 就是给存量补课的 —— 拿到手 1 秒内自动修好。

【★ 为什么 held 里要用 `unless items … item_model="…"` 先判一次】
  `item modify` 只要执行就会**重写组件**，哪怕值一样。而客户端把"组件变了"当成
  "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。资源包里那 13 份定义
  都带 `hand_animation_on_swap: false` 兜底，但**先判一次**才是根治。

【★ 为什么认人只认 custom_data~{zx:["<id>"]}, 不认底物】
  铁剑/钻石剑/下界合金剑是全包几十把武器共用的底物（而且 12 件剑分散在三种底物上），
  拿底物当身份必然误伤。`zx[0]` 才是武器 id。

【用法】python .workbuddy/_gen_sword_icons.py        # 生成 + 登记 + 自检
"""
import io
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DP = os.path.join(ROOT, 'sweetdream', 'data')
MOD_DIR = os.path.join(DP, 'sweetdream', 'item_modifier', 'sword_icons')
FN_DIR = os.path.join(DP, 'sweetdream', 'function', 'visual')
TAG = os.path.join(DP, 'manacore', 'tags', 'function', 'event', 'second.json')
RP = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream', 'items')

# ---------------------------------------------------------------- 名单（唯一真相来源）
# (武器 id, 中文名, 底物)  —— 底物只用于自检"图标挂在正确的原版轮廓上", 不参与生成命令。
SWORDS = [
    ('everfrost',    '永霜',  'diamond_sword'),
    ('hengdao',      '横刀',  'iron_sword'),
    ('hush',         '无息',  'diamond_sword'),
    ('liaoyuan',     '燎原',  'netherite_sword'),
    ('liuguang',     '流光',  'iron_sword'),
    ('myriad',       '万念',  'iron_sword'),
    ('qiansan',      '千散',  'iron_sword'),
    ('rebound',      '回锋',  'iron_sword'),
    ('remelt',       '热熔',  'netherite_sword'),
    ('rogue_star',   '游星',  'diamond_sword'),
    ('shadow_blade', '影刃',  'diamond_sword'),
    ('verdict',      '神裁',  'netherite_sword'),
    # 批 12 外观（2026-10-18）：三件新剑的 16×16 平面图标
    ('tidemark',     '潮痕',  'iron_sword'),
    ('grayscale',    '灰度',  'iron_sword'),
    ('crescent',     '缺月',  'netherite_sword'),
    # 批 16 外观（2026-10-18）：批 14 那批"只做了 give"的剑，补齐平面图标
    ('backflow_tide', '退汐', 'iron_sword'),
    ('blind_candle', '盲烛',  'diamond_sword'),
    ('blood_loss',   '失血',  'diamond_sword'),
    ('thunder_wedge', '雷楔', 'diamond_sword'),
]
# 火种**不在这里** —— 它有两态、由 equipment/sword/tinder/visual/sync 按 zx.td_on 切，
# 不参与"一把剑对应固定一个图标"的这套机制。
REG_ENTRY = 'sweetdream:visual/sword_icon_sync'

HELD_HEADER = """# ============================================================
# sweetdream:visual/sword_icon_held —— 手持扫描: 把还没有图标的剑补上 item_model
# ------------------------------------------------------------
# 【谁调用它】visual/sword_icon_sync(每秒一次, 挂 event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 staff/crossbow 两个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一把剑, 把它的 item_model 写成
#   sweetdream:<id>。lore / 升级与超限数据 / 技能数据 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只认 zx[0]，
#      不认底物: iron_sword / diamond_sword / netherite_sword 是全包几十把武器
#      共用的底物, 拿底物当身份必然误伤。
#   ② `unless items … *[minecraft:item_model="sweetdream:<id>"]` —— 已经是它了就**不写**。
#      item modify 只要执行就会重写组件, 哪怕值没变; 客户端把"组件变了"当成
#      "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。
#      (资源包 13 份定义都带 hand_animation_on_swap:false 兜底, 但先判一次才是根治。)
#
# 【新 give 出来的剑本来就有 item_model】这里主要是给**存量**补课 ——
#   玩家背包里在本次改动之前就发出去的那些剑, 拿到手 1 秒内会被修好。
#
# no-equip-check-ok: 每一处 item_modify 都由"武器 id + 当前 item_model"双重门控,
#   不依赖穿着/手持判定, 漏判也不会影响别人。
# ============================================================
"""

SYNC = """# Once per second, refresh held legacy sword icons without altering gameplay.
# no-equip-check-ok: every mutation in sword_icon_held is guarded by item id and model.
execute as @a[tag=!test_pending_return] run function sweetdream:visual/sword_icon_held
"""


def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    print('  write', os.path.relpath(path, ROOT))


def build_modifiers():
    for sid, cn, _ in SWORDS:
        data = {
            "function": "minecraft:set_components",
            "components": {"minecraft:item_model": "sweetdream:%s" % sid},
        }
        w(os.path.join(MOD_DIR, sid + '.json'),
          json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def build_held():
    L = [HELD_HEADER.rstrip('\n')]
    for sid, cn, _ in SWORDS:
        for slot in ('mainhand', 'offhand'):
            L.append(
                'execute if items entity @s weapon.%s *[minecraft:custom_data~{zx:["%s"]}]'
                ' unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
                ' run item modify entity @s weapon.%s sweetdream:sword_icons/%s'
                % (slot, sid, slot, sid, slot, sid))
    w(os.path.join(FN_DIR, 'sword_icon_held.mcfunction'), '\n'.join(L) + '\n')


def build_sync():
    w(os.path.join(FN_DIR, 'sword_icon_sync.mcfunction'), SYNC)


def register():
    """幂等登记到 event/second.json —— 顺序稳定, 重复跑不会重复加。"""
    raw = io.open(TAG, encoding='utf-8').read()
    d = json.loads(raw)
    before = list(d['values'])
    if REG_ENTRY not in d['values']:
        d['values'].append(REG_ENTRY)
    out = json.dumps(d, ensure_ascii=False, indent=2) + '\n'
    if out != raw:
        io.open(TAG, 'w', encoding='utf-8', newline='\n').write(out)
        print('  write', os.path.relpath(TAG, ROOT),
              '(%d -> %d 条)' % (len(before), len(d['values'])))
    else:
        print('  注册已存在, 未改动', os.path.relpath(TAG, ROOT))


def verify():
    errs = []
    for sid, cn, base in SWORDS:
        # 1) 资源包里要有对应的 items 定义, 且带 hand_animation_on_swap:false
        p = os.path.join(RP, sid + '.json')
        if not os.path.isfile(p):
            errs.append('资源包缺定义 %s.json —— 数据包写了 item_model 也没得用' % sid)
        else:
            j = json.load(io.open(p, encoding='utf-8'))
            if j.get('hand_animation_on_swap') is not False:
                errs.append('%s.json 缺 hand_animation_on_swap:false -> 会在手上一直抽搐' % sid)
        # 2) item_modifier 存在且指向自己
        mp = os.path.join(MOD_DIR, sid + '.json')
        if not os.path.isfile(mp):
            errs.append('缺 item_modifier %s.json' % sid)
        else:
            m = json.load(io.open(mp, encoding='utf-8'))
            if m.get('components', {}).get('minecraft:item_model') != 'sweetdream:%s' % sid:
                errs.append('item_modifier %s.json 指向的 item_model 不是自己' % sid)
    # 3) held 里每把剑都有主手+副手两行, 且都带 unless 守卫
    held = io.open(os.path.join(FN_DIR, 'sword_icon_held.mcfunction'), encoding='utf-8').read()
    for sid, cn, _ in SWORDS:
        for slot in ('mainhand', 'offhand'):
            line = ('unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
                    % (slot, sid))
            if line not in held:
                errs.append('held 缺 %s 的 %s 守卫' % (sid, slot))
    # 4) 登记
    if REG_ENTRY not in json.loads(io.open(TAG, encoding='utf-8').read())['values']:
        errs.append('event/second.json 没有登记 ' + REG_ENTRY)

    if errs:
        print('\n'.join('  ✗ ' + e for e in errs))
        raise SystemExit('自检未通过, 共 %d 条' % len(errs))
    print('自检通过：%d 件剑 · item_modifier/%d 份 · held 主副手各 1 行 · 已登记 event/second'
          % (len(SWORDS), len(SWORDS)))


def main():
    build_modifiers()
    build_held()
    build_sync()
    register()
    print()
    verify()


if __name__ == '__main__':
    main()
