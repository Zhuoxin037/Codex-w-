$execute unless score #ray_$(steps) sdbf.step matches 4.. run return 0
execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute positioned ~-0.28 ~-0.6 ~-0.28 run tag @a[gamemode=!creative,gamemode=!spectator,dx=0.56,dy=1.1,dz=0.56] add sd.fb.hit
execute positioned ~-0.28 ~-0.6 ~-0.28 run tag @e[tag=sd.fb.target,type=!minecraft:player,dx=0.56,dy=1.1,dz=0.56] add sd.fb.hit
$execute positioned ^ ^ ^0.4 run function sweetdream:boss/fireaxe/ray/5 {steps:$(steps)}
