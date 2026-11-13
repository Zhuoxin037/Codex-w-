# -*- coding: utf-8 -*-
"""
_gen_offhand_visual.py —— 7 件「副手 · 被动」道具的「数据包侧外观接入」（幂等，可反复跑）。

做四件事：
  ① item_modifier/offhand_icons/<id>.json —— set_components: item_model
     （给**存量**道具补课用；give 里已经直接写好了这个组件）
  ② function/visual/tool_icon_sync.mcfunction —— 每秒入口（挂 manacore:event/second）
  ③ function/visual/tool_icon_held.mcfunction —— 逐件扫描（7 行 = 一件一行）
  ④ 7 件 give.mcfunction 里插入 item_model（只插一次，已有则跳过）

★ 这 7 件是**手写 give**（文件头注释写明「不是 _gen_batch5.py 的产物」），
  所以这里改 give 不会被那两个生成器重跑打掉，`_chk_gen_drift.py` 也不管它们。
★ 底物全部是原版 recovery_compass；判定槽位 = `weapon.offhand`
  （与这 7 件自己的 second 函数、以及全包 137 处 `if items entity @s weapon.offhand` 同款）。
★ **观测镜 look 不在本脚本范围** —— 它 2026-10-05 就有独立平面图标了（走 ① 覆盖组）。
★ 资源包侧（图标定义/模型/贴图）由 build_vanilla_pack.py 的 ⑤ 副手组负责：
  `item_model` → assets/sweetdream/items/tool_<id>.json
               → models/item/vanilla/tool_<id>.json（minecraft:item/generated）
               → textures/item/vanilla/tool_<id>.png（16×16）
"""
import io
import json
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_offhand_icons import ICONS as TOOL_ICONS              # noqa: E402

DATA = r'D:\数据包\sweetdream\data\sweetdream'
MOD_DIR = os.path.join(DATA, 'item_modifier', 'offhand_icons')
FUNC_DIR = os.path.join(DATA, 'function', 'visual')
GIVE_ROOT = os.path.join(DATA, 'function', 'equipment', 'tool')
SECOND = r'D:\数据包\sweetdream\data\manacore\tags\function\event\second.json'

SLOT = 'weapon.offhand'          # 副手槽（items 判定 / item modify 都用这个名）
# 批 16 外观（2026-10-18）：批 14 那批"只做了 give"的副手，补齐平面图标。
#   ★ 这三件不在 build_offhand_icons.ICONS 里（那份画的是原版风矢量的 7 件），
#     贴图由 _gen_late_icons.py 生成（骨架换色，key 同样是 tool_<id>），
#     所以只在这里补名字：modifier / held / give 三处的写法与那 7 件逐字同构。
NEW_TOOLS = [('coffin_silk', '殓丝'), ('frostmirror', '冰鉴'), ('tide_buckle', '回潮扣'),
             ('dream_waker', '醒梦仪'), ('echo_harmony', '应和'), ('grimoire', '魔导书'),
             ('retro_shine', '反照'), ('sip_frost', '饮霜')]
TOOLS = sorted([(pid, cn) for pid, cn, _motif, _fn in TOOL_ICONS] + NEW_TOOLS)


def key(pid):
    return 'tool_' + pid


def comp(pid):
    """give / item_modifier 里那份 item_model 组件片段（两处逐字一致）。"""
    return 'minecraft:item_model="sweetdream:%s"' % key(pid)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='\n').write(text)


# ---------------------------------------------------------------- ① item_modifier
def gen_modifiers():
    n = 0
    for pid, _cn in TOOLS:
        data = {
            "function": "minecraft:set_components",
            "components": {"minecraft:item_model": "sweetdream:" + key(pid)},
        }
        write(os.path.join(MOD_DIR, pid + '.json'),
              json.dumps(data, ensure_ascii=False, indent=2) + '\n')
        n += 1
    print('item_modifier/offhand_icons/*.json  %d 个' % n)


# ---------------------------------------------------------------- ② 每秒入口
SYNC = """# Once per second, refresh legacy offhand-tool visuals (16x16 icon).
# 这 7 件底物都是原版 recovery_compass, 判定槽位 = weapon.offhand。
# no-equip-check-ok: 每次改写都由"道具 id + 当前 item_model"双重门控, 不依赖手持判定;
#   漏判只会白写一次组件, 不会影响别的装备。
execute as @a[tag=!test_pending_return] run function sweetdream:visual/tool_icon_held
"""


# ---------------------------------------------------------------- ③ 逐件扫描
def gen_held():
    lines = ['# 每秒仅给主副手中的旧饰品补模型；已正确绑定时不重复改写。',
             '# 只改 item_model，不改变实际技能生效槽位、强化、职业或其他组件。']
    for pid, _cn in TOOLS:
        for slot in ('weapon.mainhand', 'weapon.offhand'):
            lines.append('execute if items entity @s %s *[minecraft:custom_data~{zx:["%s"]}] '
                         'unless items entity @s %s *[minecraft:item_model="sweetdream:%s"] '
                         'run item modify entity @s %s sweetdream:offhand_icons/%s'
                         % (slot, pid, slot, key(pid), slot, pid))
    return '\n'.join(lines) + '\n'


# ---------------------------------------------------------------- ④ give 插入
def patch_give():
    changed, skipped = 0, 0
    for pid, cn in TOOLS:
        path = os.path.join(GIVE_ROOT, pid, 'give.mcfunction')
        if not os.path.isfile(path):
            raise SystemExit('✗ 找不到 give: ' + path)
        src = io.open(path, encoding='utf-8').read()
        lines = src.split('\n')
        hit = False
        for i, ln in enumerate(lines):
            if not ln.startswith('give @s '):
                continue
            if '"sweetdream:' + key(pid) + '"' in ln:
                hit = True
                break
            if not ln.rstrip().endswith(']'):
                raise SystemExit('✗ give 行不以 ] 结尾: %s\n%s' % (pid, ln))
            lines[i] = ln.rstrip()[:-1] + ',%s]' % comp(pid)
            hit = True
            break
        if not hit:
            raise SystemExit('✗ %s 里没有 give @s 行' % pid)
        new = '\n'.join(lines)
        if new == src:
            skipped += 1
            continue
        io.open(path, 'w', encoding='utf-8', newline='\n').write(new)
        changed += 1
    print('give 插入: 改 %d / 已是目标态 %d' % (changed, skipped))


# ---------------------------------------------------------------- ④ 注册每秒
def register_second():
    data = json.loads(io.open(SECOND, encoding='utf-8').read())
    vals = data['values']
    want = 'sweetdream:visual/tool_icon_sync'
    if want in vals:
        print('event/second 已登记(跳过)')
        return
    anchor = 'sweetdream:visual/armor_icon_sync'
    if anchor not in vals:
        raise SystemExit('✗ event/second 里找不到 armor_icon_sync, 结构变了, 请人工确认')
    vals.insert(vals.index(anchor) + 1, want)
    io.open(SECOND, 'w', encoding='utf-8', newline='\n').write(
        json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('event/second 登记 %s' % want)


def main():
    if not os.path.isdir(os.path.dirname(MOD_DIR)):
        raise SystemExit('✗ 找不到 item_modifier 目录: ' + os.path.dirname(MOD_DIR))
    gen_modifiers()
    write(os.path.join(FUNC_DIR, 'tool_icon_sync.mcfunction'), SYNC)
    write(os.path.join(FUNC_DIR, 'tool_icon_held.mcfunction'), gen_held())
    print('visual/tool_icon_sync + tool_icon_held 已写 (%d 件)' % len(TOOLS))
    register_second()
    patch_give()


if __name__ == '__main__':
    main()
