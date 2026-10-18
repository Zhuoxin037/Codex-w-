execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute positioned ~-0.5 ~-1 ~-0.5 if entity @s[dx=0,dy=1,dz=0] run return run tag @s add sd.fb.hit
execute positioned ^ ^ ^0.4 run function sweetdream:boss/fireaxe/impact_p2/ray_2
