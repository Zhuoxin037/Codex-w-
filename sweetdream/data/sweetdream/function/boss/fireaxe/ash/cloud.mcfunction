scoreboard players add @s sdbf.death_age 1
particle minecraft:dust{color:[0.42,0.39,0.35],scale:0.9} ~ ~1.2 ~ 0.7 0.85 0.7 0.025 7 normal
tp @s ~ ~0.015 ~
execute if score @s sdbf.death_age matches 32.. run kill @s
