execute unless entity @s[tag=zx.status.yehuo] run return 0
tag @s add zx.nb_first
function sweetdream:internal/bow/payload
data modify storage zx:work a.nb_measure set value 1b
function sweetdream:internal/damage/with_from with storage zx:work a
# one snapshots the final extra-skill amount before nested damage can overwrite a.
scoreboard players operation #nb_bounce zx.meta = @s zx.nb_extra
scoreboard players operation #nb_bounce zx.meta *= #6 zx.meta
scoreboard players operation #nb_bounce zx.meta /= #10 zx.meta
execute store result storage zx:work shot_stack[-1].damage double 0.001 run scoreboard players get #nb_bounce zx.meta
effect give @s minecraft:slowness 4 1 true
execute at @s as @e[type=#sweetdream:hostile,tag=!zx.nb_first,distance=..6,sort=nearest,limit=1] run function sweetdream:equipment/bow/night_bind/jump
tag @s remove zx.nb_first
scoreboard players reset @s zx.nb_extra
