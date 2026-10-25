execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute positioned ~-0.60 ~-0.60 ~-0.60 if entity @s[dx=0.20,dy=0.20,dz=0.20] run return run scoreboard players set @s sdh.clear 1
scoreboard players add @s sdh.ray 1
execute if score @s sdh.ray matches ..30 positioned ^ ^ ^0.20 run function sweetdream:boss/husk/hit/ray
