execute unless block ~ ~ ~ #minecraft:replaceable unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ minecraft:lava run return 0
execute positioned ~-0.125 ~-0.125 ~-0.125 as @e[type=!#sweetdream:no_damage,dx=0.25,dy=0.25,dz=0.25,sort=nearest,limit=1] if data entity @s Health unless data entity @s {Health:0.0f} run tag @s add zx.debug_aim
execute if entity @e[tag=zx.debug_aim,distance=0..,limit=1] run return 1
scoreboard players add #debug_ray zx.meta 1
execute if score #debug_ray zx.meta matches ..127 positioned ^ ^ ^0.25 run function sweetdream:debug/mark_ray
