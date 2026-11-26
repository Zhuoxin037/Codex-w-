execute positioned ~-.5 ~-.5 ~-.5 run tag @e[type=!#fallendream:no_damage,dx=0,dy=0,dz=0] add zx.nr_target
particle minecraft:dust{color:[0.75,0.03,0.08],scale:1.0} ~ ~ ~ 0.04 0.04 0.04 0 2 normal
scoreboard players add #nr_steps zx.meta 1
execute if score #nr_steps zx.meta matches 25.. run return 0
execute positioned ^ ^ ^.25 run function fallendream:equipment/axe/no_return/blade_ray
