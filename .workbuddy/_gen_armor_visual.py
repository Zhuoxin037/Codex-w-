# -*- coding: utf-8 -*-
"""
_gen_armor_visual.py —— 25 件盔甲的「数据包侧外观接入」（幂等，可反复跑）。

做四件事：
  ① item_modifier/armor_icons/<id>.json —— set_components: item_model + equippable
     （给**存量**装备补课用；give 里已经直接写好了这两个组件）
  ② function/visual/armor_icon_sync.mcfunction —— 每秒入口（挂 manacore:event/second）
  ③ function/visual/armor_icon_held.mcfunction —— 逐槽位扫描（25 行 = 一件一行）
  ④ 25 件 give.mcfunction 里插入 item_model + equippable（只插一次，已有则跳过）

★ 组件的**拼装顺序必须与 _gen_batch5.py / _gen_batch6.py 的 build() 一致**
  （加在 tooltip_display 之后，行尾 `]` 之前），否则 _chk_gen_drift.py 会判成漂移。
★ equippable 一旦覆盖就是**整体替换**原版组件 ⇒ slot / asset_id / equip_sound 必须给全。
  原版穿戴音效 id 已在原版 sounds.json 核过（item.armor.equip_iron / _diamond / _netherite）。
"""
import io
import json
import os
import re
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_armor import P                                # noqa: E402

DATA = r'D:\数据包\sweetdream\data\sweetdream'
MOD_DIR = os.path.join(DATA, 'item_modifier', 'armor_icons')
FUNC_DIR = os.path.join(DATA, 'function', 'visual')
GIVE_ROOT = os.path.join(DATA, 'function', 'equipment', 'armor')
SECOND = r'D:\数据包\sweetdream\data\manacore\tags\function\event\second.json'

EQ_SLOT = {'helmet': 'head', 'chestplate': 'chest', 'leggings': 'legs', 'boots': 'feet'}
ARMOR_SOUND = {'iron': 'minecraft:item.armor.equip_iron',
               'diamond': 'minecraft:item.armor.equip_diamond',
               'netherite': 'minecraft:item.armor.equip_netherite'}
SLOT_ARMOR = {'helmet': 'armor.head', 'chestplate': 'armor.chest',
              'leggings': 'armor.legs', 'boots': 'armor.feet'}


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='\n').write(text)


def comps(p):
    """→ (item_model 片段, equippable 片段)，与两个 give 生成器逐字一致。"""
    cid, mat, slot = p['id'], p['mat'], p['slot']
    return ('item_model="sweetdream:armor_%s"' % cid,
            'equippable={slot:"%s",asset_id:"sweetdream:armor_%s",equip_sound:"%s"}'
            % (EQ_SLOT[slot], cid, ARMOR_SOUND[mat]))


# ---------------------------------------------------------------- ① item_modifier
def gen_modifiers():
    n = 0
    for p in P:
        im, eq = comps(p)
        data = {
            "function": "minecraft:set_components",
            "components": {
                "minecraft:item_model": "sweetdream:armor_%s" % p['id'],
                "minecraft:equippable": {
                    "slot": EQ_SLOT[p['slot']],
                    "asset_id": "sweetdream:armor_%s" % p['id'],
                    "equip_sound": ARMOR_SOUND[p['mat']],
                },
            },
        }
        write(os.path.join(MOD_DIR, p['id'] + '.json'),
              json.dumps(data, ensure_ascii=False, indent=2) + '\n')
        n += 1
    print('item_modifier/armor_icons/*.json  %d 个' % n)


# ---------------------------------------------------------------- ② 每秒入口
SYNC = """# Once per second, refresh worn legacy armor visuals (icon + equipped layer).
# 盔甲没有"手持"概念 ⇒ 扫描的是四个穿戴槽位(armor.head/chest/legs/feet)。
# no-equip-check-ok: 每次改写都由"装备 id + 当前 item_model"双重门控, 不依赖穿戴判定;
#   漏判只会白写一次组件, 不会影响别的装备。
execute as @a[tag=!test_pending_return] run function sweetdream:visual/armor_icon_held
"""


def gen_held():
    L = []
    A = L.append
    A('# ============================================================')
    A('# sweetdream:visual/armor_icon_held —— 穿戴扫描: 给还没上外观的盔甲补组件')
    A('# ------------------------------------------------------------')
    A('# 【谁调用它】visual/armor_icon_sync(每秒一次, 挂 manacore:event/second)')
    A('# 【执行者】每个玩家(as @a 后逐个; 与 sword/axe/staff/crossbow 四个图标扫描同构)')
    A('#')
    A('# 【只做一件事】按 custom_data.zx[0] 认出是哪一件, 一次把两个组件写全:')
    A('#   · item_model = sweetdream:armor_<id>            (背包/手里的 16×16 图标)')
    A('#   · equippable = {slot, asset_id, equip_sound}    (穿在身上的穿戴层贴图)')
    A('#   lore / 技能数据 / 升级与超限 / 附魔 / 耐久 一律不碰。')
    A('#')
    A('# 【★ 两道门, 缺一不可】')
    A('#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只看 zx[0],')
    A('#      不看底物: 铁/钻石/下界合金的四种部位是全包 25 件共用的底物, 拿底物当')
    A('#      身份必然误伤(比如"焚舟"和"沉溺忘川彼岸"都是下界合金靴)。')
    A('#   ② `unless items … *[minecraft:item_model="sweetdream:armor_<id>"]` ——')
    A('#      已经是它了就不写。item modify 只要执行就会重写组件, 哪怕值没变;')
    A('#      客户端把"组件变了"当成"换了一件物品"。')
    A('#')
    A('# 【★ 一件盔甲只扫它自己的槽位】部位互斥(头盔在 armor.head、护腿在 armor.legs…)')
    A('#   ⇒ 总行数 = 25, 不是 25×4。**背包/箱子里的存量盔甲这里看不到** ——')
    A('#   那些请重新 give(give 里已直接写了这两个组件)。')
    A('# ============================================================')
    for p in P:
        im, eq = comps(p)
        cid = p['id']
        slot = SLOT_ARMOR[p['slot']]
        A('# %s' % p['cn'])
        A('execute if items entity @s %s *[minecraft:custom_data~{zx:["%s"]}] '
          'unless items entity @s %s *[minecraft:item_model="sweetdream:armor_%s"] '
          'run item modify entity @s %s sweetdream:armor_icons/%s'
          % (slot, cid, slot, cid, slot, cid))
    return '\n'.join(L) + '\n'


# ---------------------------------------------------------------- ④ give 插入
def patch_give():
    changed, skipped = 0, 0
    for p in P:
        cid = p['id']
        path = os.path.join(GIVE_ROOT, cid, 'give.mcfunction')
        if not os.path.isfile(path):
            raise SystemExit('✗ 找不到 give: ' + path)
        im, eq = comps(p)
        src = io.open(path, encoding='utf-8').read()
        lines = src.split('\n')
        hit = False
        for i, ln in enumerate(lines):
            if not ln.startswith('give @s '):
                continue
            if '"sweetdream:armor_' in ln:
                hit = True
                break
            if not ln.rstrip().endswith(']'):
                raise SystemExit('✗ give 行不以 ] 结尾: %s\n%s' % (cid, ln))
            lines[i] = ln.rstrip()[:-1] + ',%s,%s]' % (im, eq)
            hit = True
            break
        if not hit:
            raise SystemExit('✗ %s 里没有 give @s 行' % cid)
        new = '\n'.join(lines)
        if new == src:
            skipped += 1
            continue
        io.open(path, 'w', encoding='utf-8', newline='\n').write(new)
        changed += 1
    print('give 插入: 改 %d / 已是目标态 %d' % (changed, skipped))


# ---------------------------------------------------------------- ③ 注册每秒
def register_second():
    txt = io.open(SECOND, encoding='utf-8').read()
    data = json.loads(txt)
    vals = data['values']
    want = 'sweetdream:visual/armor_icon_sync'
    if want in vals:
        print('event/second 已登记(跳过)')
        return
    if 'sweetdream:visual/axe_icon_sync' not in vals:
        raise SystemExit('✗ event/second 里找不到 axe_icon_sync, 结构变了, 请人工确认')
    vals.insert(vals.index('sweetdream:visual/axe_icon_sync') + 1, want)
    io.open(SECOND, 'w', encoding='utf-8', newline='\n').write(
        json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('event/second 登记 %s' % want)


def main():
    if not os.path.isdir(os.path.dirname(MOD_DIR)):
        raise SystemExit('✗ 找不到 item_modifier 目录: ' + os.path.dirname(MOD_DIR))
    gen_modifiers()
    write(os.path.join(FUNC_DIR, 'armor_icon_sync.mcfunction'), SYNC)
    write(os.path.join(FUNC_DIR, 'armor_icon_held.mcfunction'), gen_held())
    print('visual/armor_icon_sync + armor_icon_held 已写 (%d 件)' % len(P))
    register_second()
    patch_give()


if __name__ == '__main__':
    main()
