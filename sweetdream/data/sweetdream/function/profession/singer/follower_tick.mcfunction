scoreboard players remove @s zx.j_life 1
particle minecraft:note ~ ~1 ~ .2 .35 .2 0 1 force
effect give @e[type=!#sweetdream:no_damage,distance=..3] minecraft:slowness 1 2 true
execute if score @s zx.j_life matches 0 run tag @s add zx.j_return
execute if entity @s[tag=zx.j_return] run function sweetdream:profession/singer/return
