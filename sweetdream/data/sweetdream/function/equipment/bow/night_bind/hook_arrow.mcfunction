# Always clear the transient context, including melee calls; never borrow another arrow.
tag @e[tag=zx.nb_arrow,distance=0..] remove zx.nb_arrow
data remove storage zx:work shot_hit
execute unless entity @s[type=#sweetdream:cc_arrow] run return 0
execute if entity @s[tag=zx.review_proc] run return 0
execute unless data entity @s weapon.components."minecraft:custom_data".sd_shot{id:"night_bind",paid:1b} run return 0
data modify storage zx:work shot_hit set from entity @s weapon.components."minecraft:custom_data".sd_shot
tag @s add zx.nb_arrow
