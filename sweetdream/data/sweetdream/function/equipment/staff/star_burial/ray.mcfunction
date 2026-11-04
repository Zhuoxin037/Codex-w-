execute positioned ~-.5 ~-.5 ~-.5 run tag @e[type=!#sweetdream:no_damage,dx=0,dy=0,dz=0,sort=nearest,limit=1] add zx.burial_pick
execute if entity @e[tag=zx.burial_pick,distance=0..,limit=1] run return 1
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
scoreboard players add #burial_steps zx.meta 1
execute if score #burial_steps zx.meta matches 64.. run return 0
execute positioned ^ ^ ^.25 run function sweetdream:equipment/staff/star_burial/ray
