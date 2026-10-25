$execute unless entity @e[tag=sd.kn.body,scores={sdk.id=$(owner)},distance=0..,limit=1] run return run function sweetdream:boss/knight/cleanup_one
$execute if entity @e[tag=sd.kn.body,tag=zx.stop,scores={sdk.id=$(owner)},distance=0..,limit=1] run return 0
execute if score @s sdk.active matches 0 run return 0
scoreboard players add @s sdk.age 1
execute if score @s sdk.age matches 1 run particle minecraft:dust{color:[0.19,0.09,0.3],scale:0.5} ~ ~ ~ 0.1 0.25 0.1 0 2 normal
execute if score @s sdk.age matches 10 run particle minecraft:dust{color:[0.73,0.6,0.95],scale:0.65} ~ ~ ~ 0.12 0.35 0.12 0 5 normal
execute if score @s sdk.age matches 10 run playsound minecraft:block.amethyst_block.chime hostile @a[distance=..12] ~ ~ ~ 0.06 1.2
execute if score @s sdk.age matches 20 run function sweetdream:boss/knight/echo/strike with storage sweetdream:knight wave
execute if score @s sdk.age matches 24.. run function sweetdream:boss/knight/echo/retire with storage sweetdream:knight wave
