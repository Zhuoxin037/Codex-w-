import io, sys
BASE = 'fallendream/data/fallendream/function/equipment/staff/renew_fire/'


def sub(p, pairs):
    s = io.open(p, encoding='utf-8').read()
    for a, b in pairs:
        if a not in s:
            print('MISS', p, repr(a[:70]))
            sys.exit(1)
        s = s.replace(a, b, 1)
    io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
    print('ok', p)


OL_BLOCK = (
    '# ①.2 拍下超限乘区(同批法杖一致; 本件三条乘区都是 0, mod 会直接返回)\n'
    'function fallendream:overlimit/api/snap\n'
    '\n'
    '# ①.3 超限分档: 手里这把是不是「超限·续火」\n'
    '#   ★ 法杖类沿用折径/惑梦的做法: 就地判物品组件, 不另建 is_ol 文件 ★\n'
    'scoreboard players set #rf_ol zx.meta 0\n'
    'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["renew_fire"],ol:"renew_fire"}] run scoreboard players set #rf_ol zx.meta 1\n'
    'execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["renew_fire"],ol:"renew_fire"}] run scoreboard players set #rf_ol zx.meta 1\n'
    '#   ★ 档位跟着"这一次普攻"走 ★ 命中回波(reward)是跨刻跑的, 那一刻玩家手里可能\n'
    '#     已经换了东西; 所以在发射当刻拍成玩家账本, reward 直接读账本。\n'
    'scoreboard players operation @s zx.rf_olk = #rf_ol zx.meta\n'
    '\n'
)

sub(BASE + 'attack.mcfunction', [
    ('# ①.2 拍下超限乘区(同批法杖一致; 本件暂无超限石, mod 会直接返回)\n'
     'function fallendream:overlimit/api/snap\n\n'
     '# ② 只读检查: 魔力 20(普攻不进冷却)\n'
     'data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:rf_attack",mana:20.0}\n',
     OL_BLOCK +
     '# ② 只读检查: 魔力 20 / 超限 15(普攻不进冷却)\n'
     'data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:rf_attack",mana:20.0}\n'
     'execute if score #rf_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 15.0\n'),

    ('# ③ 扣魔力 20(超限后的值)\n'
     'data modify storage manacore:in arg set value {uuid:"",value:20.0}\n',
     '# ③ 扣魔力 20 / 超限 15(超限后的值)\n'
     'data modify storage manacore:in arg set value {uuid:"",value:20.0}\n'
     'execute if score #rf_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 15.0\n'),

    ('# ④ 算伤害: 固定 5\n'
     'data modify storage manacore:in arg set value {uuid:"",custom_damage:5.0}\n',
     '# ④ 算伤害: 固定 5 / 超限 6\n'
     'data modify storage manacore:in arg set value {uuid:"",custom_damage:5.0}\n'
     'execute if score #rf_ol zx.meta matches 1 run data modify storage manacore:in arg.custom_damage set value 6.0\n'),
])
