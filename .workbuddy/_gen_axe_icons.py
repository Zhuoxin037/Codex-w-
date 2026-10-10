# -*- coding: utf-8 -*-
"""_gen_axe_icons.py —— 生成「斧类平面图标」的数据包侧驱动（唯一真相来源）

与 `_gen_sword_icons.py` 完全同构，只是换成 14 件斧。为什么再来一份：

  · 斧的 icon_modifier / held 扫描 / 每秒入口都按**武器类别**分开摆，
    与既有的 sword_icons / staff_icons / crossbow_icons 三个同族保持一致；
    合成一个巨型函数会让每秒扫描一次遍历 40+ 件武器。
  · 分开之后某类出问题只会影响这一类，不会连坐。

【产出三样东西】
  ① item_modifier/axe_icons/<id>.json —— 给一件斧写上自己的 item_model
  ② function/visual/axe_icon_held.mcfunction —— 手持扫描，把**还没改过的**补上
  ③ function/visual/axe_icon_sync.mcfunction —— 每秒入口（挂 event/second）
  ＋ 幂等登记 `sweetdream:visual/axe_icon_sync` 到
     data/manacore/tags/function/event/second.json

【★ 为什么 held 里要用 `unless items … item_model="…"` 先判一次】
  `item modify` 只要执行就会**重写组件**，哪怕值一样。而客户端把"组件变了"当成
  "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。资源包里那 14 份定义
  都带 `hand_animation_on_swap: false` 兜底，但**先判一次**才是根治。

【★ 为什么认人只认 custom_data~{zx:["<id>"]}, 不认底物】
  铁斧/钻石斧/下界合金斧是全包几十把武器共用的底物，拿底物当身份必然误伤。

【★★ 崩裂的模型键是 fissure_axe, 不是 fissure】
  老包 sweetdream_rp 里 `sweetdream:fissure` **已经被占用** —— 那是崩裂技能的
  「地面裂缝」平面模型（equipment/axe/fissure/field.mcfunction 用 item_display +
  item_model="sweetdream:fissure" 召唤，横平面贴地、scale 6）。
  斧要是也叫 fissure，物品就会显示成一块贴地的裂缝。所以这里 item_id 仍是
  `fissure`（zx[0] 认人用），模型键单独走 `fissure_axe`。

【用法】python .workbuddy/_gen_axe_icons.py        # 生成 + 登记 + 自检
"""
import io
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DP = os.path.join(ROOT, 'sweetdream', 'data')
MOD_DIR = os.path.join(DP, 'sweetdream', 'item_modifier', 'axe_icons')
FN_DIR = os.path.join(DP, 'sweetdream', 'function', 'visual')
TAG = os.path.join(DP, 'manacore', 'tags', 'function', 'event', 'second.json')
RP = os.path.join(ROOT, 'sweetdream_rp_原版风', 'assets', 'sweetdream', 'items')

# ---------------------------------------------------------------- 名单（唯一真相来源）
# (武器 id = zx[0], 中文名, 底物, 模型键)
#   底物只用于自检"图标挂在正确的原版轮廓上", 不参与生成命令。
#   模型键默认 = 武器 id；崩裂例外（见上面 ★★）。
AXES = [
    ('agony',        '苦痛',     'netherite_axe', 'agony'),
    ('anion',        '负离子',   'iron_axe',      'anion'),
    ('azure_star',   '苍蓝星',   'netherite_axe', 'azure_star'),
    ('ballad',       '歌谣',     'diamond_axe',   'ballad'),
    ('charge',       '超•负•荷', 'diamond_axe',   'charge'),
    ('chenyuan',     '沉渊',     'diamond_axe',   'chenyuan'),
    ('draught',      '饮鸩',     'iron_axe',      'draught'),
    ('dream_reader', '释梦',     'diamond_axe',   'dream_reader'),
    ('fissure',      '崩裂',     'iron_axe',      'fissure_axe'),
    ('meteor',       '陨星',     'diamond_axe',   'meteor'),
    ('pyre',         '葬火',     'netherite_axe', 'pyre'),
    ('red_lotus',    '红莲',     'iron_axe',      'red_lotus'),
    ('skyvault',     '天穹',     'netherite_axe', 'skyvault'),
    ('thunderclap',  '威霆',     'netherite_axe', 'thunderclap'),
]
REG_ENTRY = 'sweetdream:visual/axe_icon_sync'

HELD_HEADER = """# ============================================================
# sweetdream:visual/axe_icon_held —— 手持扫描: 把还没有图标的斧补上 item_model
# ------------------------------------------------------------
# 【谁调用它】visual/axe_icon_sync(每秒一次, 挂 event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 sword/staff/crossbow 三个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一把斧, 把它的 item_model 写成
#   sweetdream:<模型键>。lore / 升级与超限数据 / 技能数据 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只认 zx[0]，
#      不认底物: iron_axe / diamond_axe / netherite_axe 是全包几十把武器
#      共用的底物, 拿底物当身份必然误伤。
#   ② `unless items … *[minecraft:item_model="sweetdream:<模型键>"]` —— 已经是它了就**不写**。
#      item modify 只要执行就会重写组件, 哪怕值没变; 客户端把"组件变了"当成
#      "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。
#      (资源包 14 份定义都带 hand_animation_on_swap:false 兜底, 但先判一次才是根治。)
#
# 【★ 崩裂的模型键是 sweetdream:fissure_axe, 不是 sweetdream:fissure】
#   后者在老包里已经是「地面裂缝」平面模型(fissure/field 用 item_display 召唤),
#   斧叫同一个名字会显示成一块贴地的裂缝。
#
# 【新 give 出来的斧本来就有 item_model】这里主要是给**存量**补课 ——
#   玩家背包里在本次改动之前就发出去的那些斧, 拿到手 1 秒内会被修好。
#
# no-equip-check-ok: 每一处 item_modify 都由"武器 id + 当前 item_model"双重门控,
#   不依赖穿着/手持判定, 漏判也不会影响别人。
# ============================================================
"""

SYNC = """# Once per second, refresh held legacy axe icons without altering gameplay.
# no-equip-check-ok: every mutation in axe_icon_held is guarded by item id and model.
execute as @a[tag=!test_pending_return] run function sweetdream:visual/axe_icon_held
"""


def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    print('  write', os.path.relpath(path, ROOT))


def build_modifiers():
    for sid, cn, _base, key in AXES:
        data = {
            "function": "minecraft:set_components",
            "components": {"minecraft:item_model": "sweetdream:%s" % key},
        }
        w(os.path.join(MOD_DIR, sid + '.json'),
          json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def build_held():
    L = [HELD_HEADER.rstrip('\n')]
    for sid, cn, _base, key in AXES:
        L.append('# %s' % cn)
        for slot in ('mainhand', 'offhand'):
            L.append(
                'execute if items entity @s weapon.%s *[minecraft:custom_data~{zx:["%s"]}]'
                ' unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
                ' run item modify entity @s weapon.%s sweetdream:axe_icons/%s'
                % (slot, sid, slot, key, slot, sid))
    w(os.path.join(FN_DIR, 'axe_icon_held.mcfunction'), '\n'.join(L) + '\n')


def build_sync():
    w(os.path.join(FN_DIR, 'axe_icon_sync.mcfunction'), SYNC)


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
    for sid, cn, base, key in AXES:
        # 1) 资源包里要有对应的 items 定义, 且带 hand_animation_on_swap:false
        p = os.path.join(RP, key + '.json')
        if not os.path.isfile(p):
            errs.append('资源包缺定义 %s.json（%s）—— 数据包写了 item_model 也没得用' % (key, cn))
        else:
            j = json.load(io.open(p, encoding='utf-8'))
            if j.get('hand_animation_on_swap') is not False:
                errs.append('%s.json 缺 hand_animation_on_swap:false -> 会在手上一直抽搐' % key)
        # 2) item_modifier 存在且指向模型键
        mp = os.path.join(MOD_DIR, sid + '.json')
        if not os.path.isfile(mp):
            errs.append('缺 item_modifier %s.json' % sid)
        else:
            m = json.load(io.open(mp, encoding='utf-8'))
            if m.get('components', {}).get('minecraft:item_model') != 'sweetdream:%s' % key:
                errs.append('item_modifier %s.json 指向的 item_model 不是 sweetdream:%s' % (sid, key))
    # 3) held 里每件斧都有主手+副手两行, 且都带 unless 守卫
    held = io.open(os.path.join(FN_DIR, 'axe_icon_held.mcfunction'), encoding='utf-8').read()
    for sid, cn, base, key in AXES:
        for slot in ('mainhand', 'offhand'):
            line = ('unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
                    % (slot, key))
            if line not in held:
                errs.append('held 缺 %s 的 %s 守卫' % (sid, slot))
    # 4) 登记
    if REG_ENTRY not in json.loads(io.open(TAG, encoding='utf-8').read())['values']:
        errs.append('event/second.json 没有登记 ' + REG_ENTRY)

    if errs:
        print('\n'.join('  ✗ ' + e for e in errs))
        raise SystemExit('自检未通过, 共 %d 条' % len(errs))
    print('自检通过：%d 件斧 · item_modifier/%d 份 · held 主副手各 1 行 · 已登记 event/second'
          % (len(AXES), len(AXES)))


def main():
    build_modifiers()
    build_held()
    build_sync()
    register()
    print()
    verify()


if __name__ == '__main__':
    main()
