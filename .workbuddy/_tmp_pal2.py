import io, sys, os

BASE = r'D:/数据包/fallendream/data/fallendream/function/equipment/staff/palette'

def sub(name, pairs):
    p = os.path.join(BASE, name)
    s = io.open(p, encoding='utf-8').read()
    for a, b in pairs:
        if a not in s:
            print('MISS', name, repr(a))
            sys.exit(1)
        s = s.replace(a, b, 1)
    io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
    print('ok', name)

# skill: c3 只在超限才计入（原版上限 2，c3 上的残留不该被算成第 3 份）
sub('skill.mcfunction', [
    ('execute if score @s zx.pal_c3 matches 1 run scoreboard players add #pal_red zx.meta 1',
     'execute if score #pal_ol zx.meta matches 1 if score @s zx.pal_c3 matches 1 run scoreboard players add #pal_red zx.meta 1'),
    ('execute if score @s zx.pal_c3 matches 2 run scoreboard players add #pal_yel zx.meta 1',
     'execute if score #pal_ol zx.meta matches 1 if score @s zx.pal_c3 matches 2 run scoreboard players add #pal_yel zx.meta 1'),
    ('execute if score @s zx.pal_c3 matches 3 run scoreboard players add #pal_blu zx.meta 1',
     'execute if score #pal_ol zx.meta matches 1 if score @s zx.pal_c3 matches 3 run scoreboard players add #pal_blu zx.meta 1'),
])

# look_seg: 第三个槽
sub('look_seg.mcfunction', [
    ('scoreboard players add @s zx.pal_c1 0\nscoreboard players add @s zx.pal_c2 0\nexecute if score @s zx.pal_c1 matches 0 if score @s zx.pal_c2 matches 0 run return 0',
     'scoreboard players add @s zx.pal_c1 0\n'
     'scoreboard players add @s zx.pal_c2 0\n'
     'scoreboard players add @s zx.pal_c3 0\n'
     'execute if score @s zx.pal_c1 matches 0 if score @s zx.pal_c2 matches 0 if score @s zx.pal_c3 matches 0 run return 0'),
    ('execute if score @s zx.pal_c2 matches 3 run data modify storage zx:look xline append value {"text":"蓝","color":"blue"}',
     'execute if score @s zx.pal_c2 matches 3 run data modify storage zx:look xline append value {"text":"蓝","color":"blue"}\n'
     '\n'
     '# ---- 槽 ③（超限第三份；原版永远是 0，不会显示） ----\n'
     'execute if score @s zx.pal_c3 matches 1.. run data modify storage zx:look xline append value {"text":"·","color":"dark_gray"}\n'
     'execute if score @s zx.pal_c3 matches 1 run data modify storage zx:look xline append value {"text":"红","color":"red"}\n'
     'execute if score @s zx.pal_c3 matches 2 run data modify storage zx:look xline append value {"text":"黄","color":"yellow"}\n'
     'execute if score @s zx.pal_c3 matches 3 run data modify storage zx:look xline append value {"text":"蓝","color":"blue"}'),
])
