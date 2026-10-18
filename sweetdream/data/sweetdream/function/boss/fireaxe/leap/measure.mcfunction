execute positioned ~-1 ~-30 ~-1 if entity @e[tag=sd.fb.target,dx=2,dy=60,dz=2] run return 0
execute if score @s sdbf.ltotal matches 120.. run return 0
scoreboard players add @s sdbf.ltotal 1
execute positioned ^ ^ ^0.25 run function sweetdream:boss/fireaxe/leap/measure
