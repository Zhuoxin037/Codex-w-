execute positioned ~-.35 ~-.35 ~-.35 run tag @e[type=!#sweetdream:no_damage,scores={zx.j_ess=1..},dx=.7,dy=.7,dz=.7,sort=nearest,limit=1] add zx.j_host_pick
execute if entity @e[tag=zx.j_host_pick,limit=1] run return 1
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
scoreboard players add #jhostray zx.meta 1
execute if score #jhostray zx.meta matches 48.. run return 0
execute positioned ^ ^ ^.25 run function sweetdream:profession/twin/host_ray
