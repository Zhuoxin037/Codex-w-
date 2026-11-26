execute positioned ~-.5 ~-.5 ~-.5 run tag @e[type=!#fallendream:no_damage,dx=0,dy=0,dz=0,sort=nearest,limit=1] add zx.s2_deer_target
execute if entity @e[tag=zx.s2_deer_target,distance=0..,limit=1] run return 1
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
scoreboard players add #s2_deer_step zx.meta 1
execute if score #s2_deer_step zx.meta matches 40.. run return 0
execute positioned ^ ^ ^.25 run function fallendream:equipment/axe/chase_deer/ray
