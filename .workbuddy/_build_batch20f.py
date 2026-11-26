# -*- coding: utf-8 -*-
"""批 20-F：修 check 报出的 7 条（rearm / skill_mul 通道表 / second 的 at @s）"""
import io, os, sys
sys.stdout.reconfigure(encoding='utf-8')
FN = r'D:/数据包/fallendream/data/fallendream/function'


def read(p):
    return io.open(p, encoding='utf-8').read()


def write(p, s):
    io.open(p, 'w', encoding='utf-8', newline='\n').write(s)


# ① lib/rearm：三个自撤销型进度
p = os.path.join(FN, 'lib/rearm.mcfunction')
t = read(p)
add = ''
for adv in ['equipment/armor/air_step_land', 'equipment/sword/oath_victory', 'equipment/sword/oath_victory_hit']:
    line = 'advancement revoke @a only fallendream:%s\n' % adv
    if line not in t:
        add += line
if add:
    if not t.endswith('\n'):
        t += '\n'
    t += '\n# ---- 批 20（2026-10-27）胜利誓约 + 踏空 ----\n' + add
    write(p, t)
    print('rearm +3')

# ② lib/skill_mul/def：两条 atk 通道
p = os.path.join(FN, 'lib/skill_mul/def.mcfunction')
t = read(p)
blk = ''
if 'wchan.oath_victory' not in t:
    blk += '# 胜利誓约（批 20）：主动突击 = 基础攻击力 ×5（atk）；领域是纯治疗/临时生命, 不走通道\n' \
           'data modify storage zx:config wchan.oath_victory set value {mm:0b,atk:1b,oth:0b}\n'
if 'wchan.air_step' not in t:
    blk += '# 踏空（批 20）：落地 = 基础攻击力 ×1（atk）\n' \
           'data modify storage zx:config wchan.air_step set value {mm:0b,atk:1b,oth:0b}\n'
if blk:
    if not t.endswith('\n'):
        t += '\n'
    t += '\n' + blk
    write(p, t)
    print('skill_mul/def +2')

# ③ lib/second：给用到 distance 的装备补 at @s
p = os.path.join(FN, 'lib/second.mcfunction')
t = read(p)
t = t.replace('execute as @a run function fallendream:equipment/armor/empty_camp/second',
              'execute as @a at @s run function fallendream:equipment/armor/empty_camp/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/lone_walk/second',
              'execute as @a at @s run function fallendream:equipment/armor/lone_walk/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/overflow/second',
              'execute as @a at @s run function fallendream:equipment/armor/overflow/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/intent/second',
              'execute as @a at @s run function fallendream:equipment/armor/intent/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/breath_hold/second',
              'execute as @a at @s run function fallendream:equipment/armor/breath_hold/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/pivot/second',
              'execute as @a at @s run function fallendream:equipment/armor/pivot/second')
t = t.replace('execute as @a run function fallendream:equipment/armor/bearing/second',
              'execute as @a at @s run function fallendream:equipment/armor/bearing/second')
write(p, t)
print('second at @s ok')

# ④ core/tick 里的蓄意也补 at @s（虽然它不用 distance，统一口径）
p = os.path.join(FN, 'core/tick.mcfunction')
t = read(p)
t = t.replace('execute as @a run function fallendream:equipment/armor/intent/tick',
              'execute as @a at @s run function fallendream:equipment/armor/intent/tick')
write(p, t)
print('tick at @s ok')
print('done')
