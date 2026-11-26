data modify storage zx:work hit_success_stack[-1].s2_measure set value {hp:0,ab:0}
execute store result storage zx:work hit_success_stack[-1].s2_measure.hp int 1 run data get entity @s Health 1000
execute store result storage zx:work hit_success_stack[-1].s2_measure.ab int 1 run data get entity @s AbsorptionAmount 1000
