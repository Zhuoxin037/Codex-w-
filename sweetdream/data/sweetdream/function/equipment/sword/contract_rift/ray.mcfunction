execute positioned ~-.35 ~-.35 ~-.35 run tag @e[type=!#sweetdream:no_damage,scores={zx.j_ess=1..},dx=.7,dy=.7,dz=.7,sort=nearest,limit=1] add zx.cr_pick
execute if entity @e[tag=zx.cr_pick,distance=0..,limit=1] run return 1
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
scoreboard players add #cr_steps zx.meta 1
execute if score #cr_steps zx.meta matches 48.. run return 0
execute positioned ^ ^ ^.25 run function sweetdream:equipment/sword/contract_rift/ray
