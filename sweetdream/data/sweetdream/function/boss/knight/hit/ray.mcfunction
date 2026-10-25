execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute positioned ~-0.74 ~-0.74 ~-0.74 if entity @s[dx=0.48,dy=0.48,dz=0.48] run return run scoreboard players set @s sdk.clear 1
scoreboard players add @s sdk.ray 1
execute if score @s sdk.ray matches ..40 positioned ^ ^ ^0.2 run function sweetdream:boss/knight/hit/ray
