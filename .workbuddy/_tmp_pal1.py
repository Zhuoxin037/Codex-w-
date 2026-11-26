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

# ---------- attack: 档位 + 魔力 40 + 伤害 3 ----------
sub('attack.mcfunction', [
    ('# ② 只读检查: 魔力 50(普攻不进冷却)',
     '# ①.5 超限分档\n'
     '#   ★ 档位随球带走（命中刻玩家可能已换手）：攒色上限 2/3 份、\n'
     '#     "连续两次命中同一只沿用上次颜色"、伤害 1/3 全在命中那一刻决定。\n'
     'scoreboard players set #pal_ol zx.meta 0\n'
     'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["palette"],ol:"palette"}] run scoreboard players set #pal_ol zx.meta 1\n'
     'execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["palette"],ol:"palette"}] run scoreboard players set #pal_ol zx.meta 1\n'
     'scoreboard players operation @s zx.pal_ol = #pal_ol zx.meta\n'
     '\n'
     '# ② 只读检查: 魔力 50 / 超限 40(普攻不进冷却)'),
    ('mana:50.0}', 'mana:40.0}'),
    ('data modify storage manacore:in arg set value {uuid:"",value:50.0}',
     'data modify storage manacore:in arg set value {uuid:"",value:40.0}'),
    ('# ③ 扣魔力 50(超限后的值)', '# ③ 扣魔力 50 / 超限 40(超限后的值)'),
    ('data modify storage zx:work ball set value {dmg:1.0,style:"palette",hit:"fallendream:equipment/staff/palette/ball_hit"}',
     'data modify storage zx:work ball set value {dmg:1.0,ol:0b,style:"palette",hit:"fallendream:equipment/staff/palette/ball_hit"}\n'
     'execute if score #pal_ol zx.meta matches 1 run data modify storage zx:work ball.dmg set value 3.0\n'
     'execute store result storage zx:work ball.ol byte 1 run scoreboard players get #pal_ol zx.meta'),
])

# ---------- skill: 档位 + 450/70 + 三槽计数 + 红 2^n ----------
sub('skill.mcfunction', [
    ('# ② 只读检查: 冷却 + 魔力 400',
     '# ①.5 超限分档（魔力 400→450 / 冷却 60→70；三色槽；红改"每份翻倍"）\n'
     'scoreboard players set #pal_ol zx.meta 0\n'
     'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["palette"],ol:"palette"}] run scoreboard players set #pal_ol zx.meta 1\n'
     'execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["palette"],ol:"palette"}] run scoreboard players set #pal_ol zx.meta 1\n'
     'scoreboard players operation @s zx.pal_ol = #pal_ol zx.meta\n'
     '\n'
     '# ② 只读检查: 冷却 + 魔力 400 / 超限 450'),
    ('mana:400.0}\ndata modify storage manacore:in arg.uuid set from storage zx:data self.uuid\ndata modify storage zx:work olv.mana set from storage manacore:in arg.mana',
     'mana:400.0}\nexecute if score #pal_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 450.0\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid\n'
     'data modify storage zx:work olv.mana set from storage manacore:in arg.mana'),
    ('# ③ 扣魔力 400', '# ③ 扣魔力 400 / 超限 450'),
    ('data modify storage manacore:in arg set value {uuid:"",value:400.0}',
     'data modify storage manacore:in arg set value {uuid:"",value:400.0}\n'
     'execute if score #pal_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 450.0'),
    ('# ④ 起冷却 60 秒', '# ④ 起冷却 60 秒 / 超限 70 秒'),
    ('cooldown_seconds:60.0,reduce:1b}',
     'cooldown_seconds:60.0,reduce:1b}\n'
     'execute if score #pal_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 70.0'),
])

# ---------- skill ⑥⑦: 三槽 + 红 2^n ----------
sub('skill.mcfunction', [
    ('# ⑥ 数颜色: 红/黄/蓝 各几个(zx.pal_c1 / zx.pal_c2 两个槽)',
     '# ⑥ 数颜色: 红/黄/蓝 各几个(zx.pal_c1 / c2 / c3 三个槽；原版 c3 恒为 0)'),
    ('execute if score @s zx.pal_c2 matches 1 run scoreboard players add #pal_red zx.meta 1\nexecute if score @s zx.pal_c1 matches 2 run scoreboard players add #pal_yel zx.meta 1',
     'execute if score @s zx.pal_c2 matches 1 run scoreboard players add #pal_red zx.meta 1\n'
     'execute if score @s zx.pal_c3 matches 1 run scoreboard players add #pal_red zx.meta 1\n'
     'execute if score @s zx.pal_c1 matches 2 run scoreboard players add #pal_yel zx.meta 1'),
    ('execute if score @s zx.pal_c2 matches 2 run scoreboard players add #pal_yel zx.meta 1\nexecute if score @s zx.pal_c1 matches 3 run scoreboard players add #pal_blu zx.meta 1',
     'execute if score @s zx.pal_c2 matches 2 run scoreboard players add #pal_yel zx.meta 1\n'
     'execute if score @s zx.pal_c3 matches 2 run scoreboard players add #pal_yel zx.meta 1\n'
     'execute if score @s zx.pal_c1 matches 3 run scoreboard players add #pal_blu zx.meta 1'),
    ('execute if score @s zx.pal_c2 matches 3 run scoreboard players add #pal_blu zx.meta 1\n',
     'execute if score @s zx.pal_c2 matches 3 run scoreboard players add #pal_blu zx.meta 1\n'
     'execute if score @s zx.pal_c3 matches 3 run scoreboard players add #pal_blu zx.meta 1\n'),
    ('#   #pal_mul = 1 + 红数(伤害倍率; ×0.1 在 color_hit 里乘)\nscoreboard players set #pal_mul zx.meta 1\nscoreboard players operation #pal_mul zx.meta += #pal_red zx.meta',
     '#   #pal_mul = 伤害倍率（×0.1 在 color_hit 里乘）\n'
     '#     原版 "每有一个红色伤害提高 1 倍" -> 1 + 红数（1 / 2 / 3）\n'
     '#     超限 "每有一份红色伤害翻倍"     -> 2^红数（1 / 2 / 4 / 8）\n'
     'scoreboard players set #pal_mul zx.meta 1\n'
     'execute if score #pal_ol zx.meta matches 0 run scoreboard players operation #pal_mul zx.meta += #pal_red zx.meta\n'
     'execute if score #pal_ol zx.meta matches 1 if score #pal_red zx.meta matches 1 run scoreboard players set #pal_mul zx.meta 2\n'
     'execute if score #pal_ol zx.meta matches 1 if score #pal_red zx.meta matches 2 run scoreboard players set #pal_mul zx.meta 4\n'
     'execute if score #pal_ol zx.meta matches 1 if score #pal_red zx.meta matches 3 run scoreboard players set #pal_mul zx.meta 8'),
])

# ---------- skill ⑨: 清空三个槽 ----------
sub('skill.mcfunction', [
    ('scoreboard players set @s zx.pal_c1 0\nscoreboard players set @s zx.pal_c2 0',
     'scoreboard players set @s zx.pal_c1 0\nscoreboard players set @s zx.pal_c2 0\nscoreboard players set @s zx.pal_c3 0\nscoreboard players set @s zx.pal_lc 0'),
])
