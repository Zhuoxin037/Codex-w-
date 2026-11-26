execute positioned ~-.5 ~-.5 ~-.5 run tag @e[type=!#fallendream:no_damage,dx=0,dy=0,dz=0] add zx.weave_edge
particle minecraft:dust{color:[0.65,0.77,1.0],scale:.7} ~ ~ ~ 0 0 0 0 1 normal
execute if entity @e[tag=zx.weave_b,distance=..0.3,limit=1] run return 0
execute positioned ^ ^ ^.25 run function fallendream:equipment/staff/star_weave/line_b
