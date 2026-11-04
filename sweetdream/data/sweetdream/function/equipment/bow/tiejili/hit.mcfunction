data modify storage zx:work tj set from storage zx:work shot_stack[-1]
data modify storage zx:work tj.dmg set from storage zx:work tj.damage
execute unless data storage zx:work tj.s2_b_dmg run data modify storage zx:work tj.s2_b_dmg set value {n:0,d:1}
execute at @s run function sweetdream:equipment/bow/tiejili/spawn with storage zx:work tj
