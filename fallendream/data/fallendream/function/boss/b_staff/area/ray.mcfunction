execute unless block ~ ~ ~ #fallendream:b_staff_clear run return 0
execute positioned ~-0.15 ~-0.15 ~-0.15 if entity @e[tag=sd.bs.candidate,dx=0.3,dy=0.3,dz=0.3] run scoreboard players set #sight bs.ok 1
execute if score #sight bs.ok matches 1 run return 1
execute if score #ray bs.ray matches 24.. run return 0
scoreboard players add #ray bs.ray 1
execute positioned ^ ^ ^0.25 run function fallendream:boss/b_staff/area/ray
