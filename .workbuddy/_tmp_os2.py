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

# ---- 双状态: ×0.2 -> 超限 ×0.24 ----
sub('both_go.mcfunction', [
    ('data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2}\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
     'data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2}\n'
     'execute if score @s zx.os_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.24\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid'),
])

# ---- 溅射: ×0.12 -> 超限 ×0.14 ----
sub('splash_dmg.mcfunction', [
    ('data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12}\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
     'data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12}\n'
     'execute if score @s zx.os_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.14\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid'),
])

# ---- 普攻双状态真伤: ×0.03 -> 超限 ×0.04 ----
sub('passive_true.mcfunction', [
    ('data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
     'data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}\n'
     'execute if score @s zx.os_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.04\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid'),
])

# ---- 渊海 -> 噬心: ×0.1 -> 超限 ×0.12，并记下"这是反向转化的候选" ----
sub('to_shixin_go.mcfunction', [
    ('data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
     'data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}\n'
     'execute if score @s zx.os_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.12\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid'),
    ('# ⑤ 表现: 渊海被翻成噬心',
     '# ④.5 超限: 记下"这一只是「只发生标签转化」的"—— 4 秒内可用主动把它翻回去\n'
     '#   原状态只有渊海 -> 现在带噬心 -> 反向 = 噬心 -> 渊海（对应噬心分支的伤害）\n'
     'execute if score @s zx.os_ol matches 1 run tag @e[tag=zx.os_sel,tag=zx.os_y,distance=0..] add zx.os_rev_y\n'
     '\n'
     '# ⑤ 表现: 渊海被翻成噬心'),
])

# ---- 噬心 -> 渊海: ×0.08 -> 超限 ×0.1 ----
sub('to_yuanhai_go.mcfunction', [
    ('data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
     'data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}\n'
     'execute if score @s zx.os_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.1\n'
     'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid'),
    ('# ⑤ 表现: 噬心被冲回渊海',
     '# ④.5 超限: 记下反向转化候选（原状态只有噬心 -> 现在带渊海）\n'
     'execute if score @s zx.os_ol matches 1 run tag @e[tag=zx.os_sel,tag=zx.os_s,distance=0..] add zx.os_rev_s\n'
     '\n'
     '# ⑤ 表现: 噬心被冲回渊海'),
])
