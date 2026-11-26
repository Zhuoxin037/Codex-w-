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

sub('attack.mcfunction', [
    ('skill:"fallendream:os_attack",mana:80.0}', 'skill:"fallendream:os_attack",mana:70.0}'),
    ('# ② 只读检查: 魔力 80(普攻不进冷却)',
     '# ② 只读检查: 魔力 80 / 超限 70(普攻不进冷却)'),
    ('# ③ 扣魔力 80(超限后的值)',
     '# ③ 扣魔力 80 / 超限 70(超限后的值)'),
])

sub('p_gate.mcfunction', [
    ('scoreboard players add @s zx.os_pd 160', 'scoreboard players add @s zx.os_pd 80'),
])

sub('roll_shixin.mcfunction', [
    ('%= #4 zx.meta', '%= #5 zx.meta'),
    ('matches 0 run function fallendream:tag/mark {target:"@s",mark:"shixin"}',
     'matches 0..1 run function fallendream:tag/mark {target:"@s",mark:"shixin"}'),
])
sub('roll_yuanhai.mcfunction', [
    ('%= #4 zx.meta', '%= #5 zx.meta'),
    ('matches 0 run function fallendream:tag/mark {target:"@s",mark:"yuanhai"}',
     'matches 0..1 run function fallendream:tag/mark {target:"@s",mark:"yuanhai"}'),
])
