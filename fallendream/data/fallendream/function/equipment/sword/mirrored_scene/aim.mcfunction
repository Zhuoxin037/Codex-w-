scoreboard players add #s2_scene_step zx.meta 1
scoreboard players set #s2_scene_stop zx.meta 0
execute positioned ~-.5 ~-.5 ~-.5 if entity @e[type=!#fallendream:no_damage,dx=0,dy=0,dz=0] run scoreboard players set #s2_scene_stop zx.meta 1
execute unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set #s2_scene_stop zx.meta 1
execute if score #s2_scene_step zx.meta matches 128.. run scoreboard players set #s2_scene_stop zx.meta 1
execute if score #s2_scene_stop zx.meta matches 1 if loaded ~ ~ ~ run summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_ray_point"]}
execute if score #s2_scene_stop zx.meta matches 1 run data modify storage zx:work s2_scene_origin.aim set from entity @e[tag=zx.s2_ray_point,distance=..1,limit=1] Pos
execute if score #s2_scene_stop zx.meta matches 1 run kill @e[tag=zx.s2_ray_point,distance=..1]
execute if score #s2_scene_stop zx.meta matches 1 run return 0
execute positioned ^ ^ ^.5 run function fallendream:equipment/sword/mirrored_scene/aim
