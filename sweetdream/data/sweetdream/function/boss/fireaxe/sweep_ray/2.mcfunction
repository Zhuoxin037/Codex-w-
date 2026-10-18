execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute positioned ~-0.4 ~-0.7 ~-0.4 run tag @a[gamemode=!creative,gamemode=!spectator,dx=0.8,dy=1.4,dz=0.8] add sd.fb.hit
execute positioned ~-0.4 ~-0.7 ~-0.4 run tag @e[tag=sd.fb.target,type=!minecraft:player,dx=0.8,dy=1.4,dz=0.8] add sd.fb.hit
execute positioned ^ ^ ^0.4 run function sweetdream:boss/fireaxe/sweep_ray/3
