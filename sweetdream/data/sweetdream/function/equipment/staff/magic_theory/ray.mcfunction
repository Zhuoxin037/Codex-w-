particle minecraft:dust{color:[0.65,0.88,1.0],scale:0.5} ~ ~ ~ 0 0 0 0 1 force
execute positioned ~-.5 ~-.5 ~-.5 run tag @e[type=!#sweetdream:no_damage,dx=0,dy=0,dz=0,sort=nearest,limit=1] add zx.s2_rail_target
execute if entity @e[tag=zx.s2_rail_target,distance=..1,limit=1] run return 1
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
scoreboard players add #s2_rail_step zx.meta 1
execute if score #s2_rail_step zx.meta matches 160.. run return 0
execute positioned ^ ^ ^.25 run function sweetdream:equipment/staff/magic_theory/ray
