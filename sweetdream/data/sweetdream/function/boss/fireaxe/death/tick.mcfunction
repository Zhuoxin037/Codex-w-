scoreboard players add @s sdbf.death_age 1
execute at @s if block ~ ~-0.2 ~ #sweetdream:boss_passable positioned ~ ~-0.2 ~ run tp @s ~ ~ ~
execute if score @s sweetdream_boss.reconstruction.death.frame matches 17 run playsound minecraft:block.anvil.land hostile @a[distance=..32] ~ ~ ~ 0.35 0.65
execute if score @s sweetdream_boss.reconstruction.death.frame matches 52 run function sweetdream:boss/fireaxe/death/ash_0
execute if score @s sweetdream_boss.reconstruction.death.frame matches 60 run function sweetdream:boss/fireaxe/death/ash_1
execute if score @s sweetdream_boss.reconstruction.death.frame matches 60 run function sweetdream:boss/fireaxe/ash/burst_0
execute if score @s sweetdream_boss.reconstruction.death.frame matches 68 run function sweetdream:boss/fireaxe/death/ash_2
execute if score @s sweetdream_boss.reconstruction.death.frame matches 68 run function sweetdream:boss/fireaxe/ash/burst_1
execute if score @s sweetdream_boss.reconstruction.death.frame matches 76 run function sweetdream:boss/fireaxe/death/ash_3
execute if score @s sweetdream_boss.reconstruction.death.frame matches 76 run function sweetdream:boss/fireaxe/ash/burst_2
execute if score @s sweetdream_boss.reconstruction.death.frame matches 84 run function sweetdream:boss/fireaxe/death/ash_4
execute if score @s sweetdream_boss.reconstruction.death.frame matches 84 run function sweetdream:boss/fireaxe/ash/burst_3
execute if score @s sweetdream_boss.reconstruction.death.frame matches 60.. run particle minecraft:dust{color:[0.38,0.36,0.33],scale:0.8} ~ ~1.4 ~ 0.65 1 0.65 0.02 8 normal
execute if score @s sweetdream_boss.reconstruction.death.frame matches 88.. run return run function sweetdream:boss/fireaxe/death/end
execute if score @s sdbf.death_age matches 110.. run function sweetdream:boss/fireaxe/death/end
