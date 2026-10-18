# -*- coding: utf-8 -*-
"""_chk_axe_icon.py —— 守卫：14 件斧的「平面图标」有没有真的接上（数据包 ↔ 资源包）

与 `_chk_sword_icon.py` 同构。为什么需要它：这套东西横跨两个包，任何一环断掉都
**不报错**，只是游戏里"变成原版斧"或"缺模型"：
  · 数据包写了 item_model，资源包没定义       -> 缺模型（紫黑块）
  · 资源包有定义，give 里漏写 item_model      -> 显示原版铁斧/钻石斧
  · 两份资源包（覆盖层 / 完整版）不同步        -> 只装完整版的人看不到
  · 崩裂写成 sweetdream:fissure                -> 物品显示成一块贴地的地面裂缝
    （那个名字在老包里已经是技能的地裂平面模型）

判据（每一条都对应一次真实会踩的坑）：
  1) 资源包（覆盖层）有全部 14 份 items 定义，
     每条带 hand_animation_on_swap:false、model 可达、贴图 16×16 且与设计源**逐字节一致**
  2) 完整版里同样这 14 份，且与覆盖层**逐字节一致**（合并没漏、没走样）
  3) 数据包侧：14 份 item_modifier/axe_icons/<id>.json 存在且 item_model 指向**模型键**
     （崩裂必须指向 sweetdream:fissure_axe，不是 sweetdream:fissure）
  4) give 里**每一处**产出这些斧的物品串都带 item_model="sweetdream:<模型键>"
  5) event/second.json 登记了 sweetdream:visual/axe_icon_sync
  6) held 函数里每把斧主手 + 副手各一行，且都带 unless item_model 守卫
     （漏守卫 = 每秒重写组件 = 在手上一直抽搐）
  7) ★ sweetdream:fissure 没有被斧占用（它属于地面裂缝）

【用法】python .workbuddy/_chk_axe_icon.py   -> 0 条 = 通过
"""
import io
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DP = os.path.join(ROOT, 'sweetdream', 'data')
FUNC = os.path.join(DP, 'sweetdream', 'function')
MOD_DIR = os.path.join(DP, 'sweetdream', 'item_modifier', 'axe_icons')
TAG = os.path.join(DP, 'manacore', 'tags', 'function', 'event', 'second.json')
OVERLAY = os.path.join(ROOT, 'sweetdream_rp_原版风')
FULL = os.path.join(ROOT, 'sweetdream_rp_完整版')
ART = os.path.join(ROOT, '模型设计', '原版风_资源包_20261010', '斧_预览')

# 武器 id(zx[0]) -> (设计源文件名, 模型键)
# ★ 崩裂：设计源叫 fissure.png，但模型键必须是 fissure_axe
AXES = {
    'agony':        ('agony',        'agony'),
    'anion':        ('anion',        'anion'),
    'azure_star':   ('azure_star',   'azure_star'),
    'ballad':       ('ballad',       'ballad'),
    'charge':       ('charge',       'charge'),
    'chenyuan':     ('chenyuan',     'chenyuan'),
    'draught':      ('draught',      'draught'),
    'dream_reader': ('dream_reader', 'dream_reader'),
    'fissure':      ('fissure',      'fissure_axe'),
    'meteor':       ('meteor',       'meteor'),
    'pyre':         ('pyre',         'pyre'),
    'red_lotus':    ('red_lotus',    'red_lotus'),
    'skyvault':     ('skyvault',     'skyvault'),
    'thunderclap':  ('thunderclap',  'thunderclap'),
    # 批 12 外观（2026-10-18）：焦骨
    'scorch_bone':  ('scorch_bone',  'scorch_bone'),
    # 批 16 外观（2026-10-18）：批 14 那批只做 give 的斧（anchor 仍不挂，见 _chk_item_visual）
    'broken_page':  ('broken_page',  'broken_page'),
    'death_bell':   ('death_bell',   'death_bell'),
    'deep_brine':   ('deep_brine',   'deep_brine'),
    'frost_carve':  ('frost_carve',  'frost_carve'),
}
REG_ENTRY = 'sweetdream:visual/axe_icon_sync'

errs = []


def E(msg):
    errs.append(msg)


def check_pack(root, tag):
    """检查一份资源包里的 items 定义 / 模型 / 贴图"""
    for sid, (stem, key) in AXES.items():
        dp = os.path.join(root, 'assets', 'sweetdream', 'items', key + '.json')
        if not os.path.isfile(dp):
            E('[%s] 缺 items 定义 assets/sweetdream/items/%s.json' % (tag, key))
            continue
        d = json.load(io.open(dp, encoding='utf-8'))
        if d.get('hand_animation_on_swap') is not False:
            E('[%s] %s.json 缺 hand_animation_on_swap:false -> 会在手上一直抽搐' % (tag, key))
        if d.get('model', {}).get('type') != 'minecraft:model':
            E('[%s] %s.json 的 model.type 应为 minecraft:model' % (tag, key))
        mp = os.path.join(root, 'assets', 'sweetdream', 'models', 'item', 'vanilla', key + '.json')
        if not os.path.isfile(mp):
            E('[%s] 缺模型 assets/sweetdream/models/item/vanilla/%s.json' % (tag, key))
            continue
        tp = os.path.join(root, 'assets', 'sweetdream', 'textures', 'item', 'vanilla', key + '.png')
        if not os.path.isfile(tp):
            E('[%s] 缺贴图 assets/sweetdream/textures/item/vanilla/%s.png' % (tag, key))
            continue
        if os.path.getsize(tp) == 0:
            E('[%s] 贴图是空文件 %s' % (tag, key))
        # 尺寸 16x16（不引 PIL，直接读 PNG 头）
        with open(tp, 'rb') as f:
            hdr = f.read(24)
        if hdr[:8] != b'\x89PNG\r\n\x1a\n':
            E('[%s] 贴图不是 PNG: %s' % (tag, key))
        else:
            w = int.from_bytes(hdr[16:20], 'big')
            h = int.from_bytes(hdr[20:24], 'big')
            if (w, h) != (16, 16):
                E('[%s] 贴图尺寸 %dx%d, 应为 16x16: %s' % (tag, w, h, key))
        src = os.path.join(ART, stem + '.png')
        if os.path.isfile(src) and open(tp, 'rb').read() != open(src, 'rb').read():
            E('[%s] 贴图与设计源不一致: %s' % (tag, key))


def main():
    # ---- 1) 完整版（覆盖层 `sweetdream_rp_原版风` 已合并进完整版并删除,
    #      按旧路径遍历只会报"找不到资源包"的假警报 —— 只守真源）----
    if not os.path.isdir(FULL):
        E('找不到资源包 %s' % FULL)
    else:
        check_pack(FULL, '完整版')

    # ---- 3) item_modifier ----
    for sid, (stem, key) in AXES.items():
        mp = os.path.join(MOD_DIR, sid + '.json')
        if not os.path.isfile(mp):
            E('缺 item_modifier axe_icons/%s.json' % sid)
            continue
        m = json.load(io.open(mp, encoding='utf-8'))
        if m.get('components', {}).get('minecraft:item_model') != 'sweetdream:%s' % key:
            E('item_modifier axe_icons/%s.json 的 item_model 不是 sweetdream:%s' % (sid, key))

    # ---- 4) 每一处产出这些斧的物品串都要带 item_model ----
    pat = re.compile(r'custom_data=\{zx:\["(\w+)"')
    n_str = 0
    for r, _, fns in os.walk(FUNC):
        for fn in fns:
            if not fn.endswith('.mcfunction'):
                continue
            p = os.path.join(r, fn)
            for ln, s in enumerate(io.open(p, encoding='utf-8'), 1):
                m = pat.search(s)
                if not m or m.group(1) not in AXES:
                    continue
                if not (s.strip().startswith('give @s') or 'item replace entity @s' in s):
                    continue
                n_str += 1
                key = AXES[m.group(1)][1]
                if 'item_model="sweetdream:%s"' % key not in s:
                    E('%s L%d 产出的「%s」没带 item_model -> 会显示成原版斧'
                      % (os.path.relpath(p, ROOT), ln, m.group(1)))
                if m.group(1) == 'fissure' and 'item_model="sweetdream:fissure"' in s:
                    E('%s L%d 崩裂写成了 sweetdream:fissure -> 会显示成地面裂缝'
                      % (os.path.relpath(p, ROOT), ln))

    # ---- 5) 注册 ----
    if not os.path.isfile(TAG):
        E('找不到 event/second.json')
    elif REG_ENTRY not in json.load(io.open(TAG, encoding='utf-8'))['values']:
        E('event/second.json 没登记 ' + REG_ENTRY)

    # ---- 6) held 的守卫 ----
    hp = os.path.join(FUNC, 'visual', 'axe_icon_held.mcfunction')
    if not os.path.isfile(hp):
        E('缺 function/visual/axe_icon_held.mcfunction')
    else:
        held = io.open(hp, encoding='utf-8').read()
        for sid, (stem, key) in AXES.items():
            for slot in ('mainhand', 'offhand'):
                if ('unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
                        % (slot, key)) not in held:
                    E('held 缺 %s 的 %s 守卫(漏了会每秒重写组件 -> 抽搐)' % (sid, slot))
    if not os.path.isfile(os.path.join(FUNC, 'visual', 'axe_icon_sync.mcfunction')):
        E('缺 function/visual/axe_icon_sync.mcfunction')

    # ---- 7) ★ sweetdream:fissure 必须仍然属于地面裂缝, 不能被斧抢走 ----
    #   （覆盖层 `sweetdream_rp_原版风` 已合并进完整版并删除，只剩真源要守）
    for root, tag in ((FULL, '完整版'),):
        p = os.path.join(root, 'assets', 'sweetdream', 'items', 'fissure.json')
        if os.path.isfile(p):
            d = json.load(io.open(p, encoding='utf-8'))
            if d.get('model', {}).get('model') != 'sweetdream:item/fissure':
                E('[%s] assets/sweetdream/items/fissure.json 不再指向地面裂缝模型: %s'
                  % (tag, d.get('model', {}).get('model')))
        p2 = os.path.join(root, 'assets', 'sweetdream', 'items', 'fissure_axe.json')
        if not os.path.isfile(p2):
            E('[%s] 缺崩裂斧的定义 assets/sweetdream/items/fissure_axe.json' % tag)

    if errs:
        print('\n'.join('  ✗ ' + e for e in errs))
        raise SystemExit('\n合计问题: %d' % len(errs))
    print('斧图标绑定 ✓  资源包 1 份 × %d 件 · item_modifier %d 份 · '
          '物品串 %d 处带 item_model · 已登记 event/second · held 守卫齐全 · '
          '崩裂走 fissure_axe（fissure 仍属地面裂缝）'
          % (len(AXES), len(AXES), n_str))


if __name__ == '__main__':
    main()
