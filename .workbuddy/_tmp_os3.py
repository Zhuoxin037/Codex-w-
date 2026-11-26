import io, sys, os

BASE = r'D:/数据包/fallendream/data/fallendream/function/equipment/staff/other_shore'

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

# ---------- attack: 拍档 + 球里带 ol ----------
sub('attack.mcfunction', [
    ('# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)\n',
     '# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)\n'),
    ('# ② 只读检查: 魔力 80 / 超限 70(普攻不进冷却)',
     '# ①.5 超限分档\n'
     '#   ★ 命中回调要按"这一发是不是超限"决定：附加概率 25/40%、节流 8/4 秒、\n'
     '#     双状态真伤 0.03/0.04 —— 全是命中那刻结算的，所以档位随球一起带走。\n'
     'scoreboard players set #os_ol zx.meta 0\n'
     'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["other_shore"],ol:"other_shore"}] run scoreboard players set #os_ol zx.meta 1\n'
     'execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["other_shore"],ol:"other_shore"}] run scoreboard players set #os_ol zx.meta 1\n'
     'scoreboard players operation @s zx.os_ol = #os_ol zx.meta\n'
     '\n'
     '# ② 只读检查: 魔力 80 / 超限 70(普攻不进冷却)'),
    ('data modify storage zx:work ball set value {dmg:0.0,style:"other_shore",hit:"fallendream:equipment/staff/other_shore/ball_hit"}',
     'data modify storage zx:work ball set value {dmg:0.0,ol:0b,style:"other_shore",hit:"fallendream:equipment/staff/other_shore/ball_hit"}\n'
     'execute store result storage zx:work ball.ol byte 1 run scoreboard players get #os_ol zx.meta'),
])

# ---------- ball_hit: 先从球里取档，再跑节流 ----------
sub('ball_hit.mcfunction', [
    ('# ① 逐只过 8 秒节流(记在**被命中的生物**身上 -> 每只各自计时)',
     '# ①.0 档位：从球身上取（命中刻玩家可能已经换手；这一发是超限就是超限）\n'
     'scoreboard players set #os_ol zx.meta 0\n'
     'execute if data entity @s data{ol:1b} run scoreboard players set #os_ol zx.meta 1\n'
     '\n'
     '# ① 逐只过节流(记在**被命中的生物**身上 -> 每只各自计时；原版 8 秒 / 超限 4 秒)'),
])

# ---------- p_gate: 8 秒 / 超限 4 秒 ----------
sub('p_gate.mcfunction', [
    ('scoreboard players add @s zx.os_pd 80',
     'scoreboard players add @s zx.os_pd 160\n'
     'execute if score #os_ol zx.meta matches 1 run scoreboard players add @s zx.os_pd -80'),
    ('# 【文案】"附加效果对同一个生物 8 秒内最多触发一次。"',
     '# 【文案】"附加效果对同一个生物 8 秒内最多触发一次。"（超限：4 秒）'),
    ('# 【记录方式】zx.os_pd = 该生物"下次可以触发"的 #now 时刻 = 现在 + 160 刻(= 8 秒)。',
     '# 【记录方式】zx.os_pd = 该生物"下次可以触发"的 #now 时刻 = 现在 + 160 刻(= 8 秒);\n'
     '#   超限再 -80（= 4 秒）。档位取自 #os_ol（ball_hit 从球的 data.ol 里拍下来的）。'),
])
