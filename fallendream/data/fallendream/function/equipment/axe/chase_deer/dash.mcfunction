execute if entity @e[tag=zx.s2_deer_target,distance=..1,limit=1] run return 1
execute unless block ^ ^ ^.25 #minecraft:replaceable run return 0
execute unless block ^ ^1 ^.25 #minecraft:replaceable run return 0
tp @s ^ ^ ^.25
execute at @s run function fallendream:equipment/armor/empty_cicada/moved
scoreboard players add #s2_deer_step zx.meta 1
execute if score #s2_deer_step zx.meta matches 40.. run return 0
execute positioned ^ ^ ^.25 run function fallendream:equipment/axe/chase_deer/dash
