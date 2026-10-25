scoreboard players add @s sdk.death 1
execute if score @s sdk.death matches 58 run particle minecraft:dust{color:[0.63,0.57,0.73],scale:0.7} ~ ~1.2 ~ 0.4 0.9 0.4 0.02 35 normal
execute if score @s sdk.death matches 60.. run function sweetdream:boss/knight/remove_rig
