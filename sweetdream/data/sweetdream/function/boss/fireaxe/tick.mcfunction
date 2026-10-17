# Dimension-local selectors prevent triple ticking the same entity.
execute in minecraft:overworld as @e[tag=sd.fb.body,distance=0..] at @s run function sweetdream:boss/fireaxe/orphan_check
execute in minecraft:the_nether as @e[tag=sd.fb.body,distance=0..] at @s run function sweetdream:boss/fireaxe/orphan_check
execute in minecraft:the_end as @e[tag=sd.fb.body,distance=0..] at @s run function sweetdream:boss/fireaxe/orphan_check
scoreboard players add #bars sdbf.step 1
execute if score #bars sdbf.step matches 20.. run function sweetdream:boss/fireaxe/bar_watch
execute in minecraft:overworld as @e[tag=sd.fb.ash,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/tick
execute in minecraft:overworld as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/cloud
execute in minecraft:the_nether as @e[tag=sd.fb.ash,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/tick
execute in minecraft:the_nether as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/cloud
execute in minecraft:the_end as @e[tag=sd.fb.ash,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/tick
execute in minecraft:the_end as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run function sweetdream:boss/fireaxe/ash/cloud
