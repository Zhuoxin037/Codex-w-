execute unless score @s zx.j_host_t matches 1.. positioned ~-.45 ~ ~-.45 run tag @e[type=!#sweetdream:no_damage,tag=!zx.j_anchor,tag=!zx.j_shadow,dx=.9,dy=1.8,dz=.9] add zx.j_path_v
execute if score @s zx.j_host_t matches 1.. positioned ~-.45 ~ ~-.45 run tag @e[type=!#sweetdream:no_damage,tag=!zx.j_anchor,dx=.9,dy=1.8,dz=.9] add zx.j_path_v
particle minecraft:dust{color:[.35,.75,.9],scale:.5} ~ ~.7 ~ 0 0 0 0 1 force
scoreboard players add #jpath_step zx.meta 1
execute if score #jpath_step zx.meta matches 49.. run return 0
execute if score @s zx.j_form matches 1 if entity @e[tag=zx.j_anchor,distance=..0.6] run return 0
execute if score @s zx.j_form matches 0 if entity @e[tag=zx.j_shadow,distance=..0.6] run return 0
execute positioned ^ ^ ^.5 run function sweetdream:profession/twin/path_ray
