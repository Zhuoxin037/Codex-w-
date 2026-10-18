execute in minecraft:overworld as @e[tag=sd.fb.rig,distance=0..] at @s run function sweetdream:boss/fireaxe/remove_rig
execute in minecraft:overworld run kill @e[tag=sd.fb.body,distance=0..]
execute in minecraft:the_nether as @e[tag=sd.fb.rig,distance=0..] at @s run function sweetdream:boss/fireaxe/remove_rig
execute in minecraft:the_nether run kill @e[tag=sd.fb.body,distance=0..]
execute in minecraft:the_end as @e[tag=sd.fb.rig,distance=0..] at @s run function sweetdream:boss/fireaxe/remove_rig
execute in minecraft:the_end run kill @e[tag=sd.fb.body,distance=0..]
execute in minecraft:overworld as @e[tag=sd.fb.ash,distance=0..] at @s run kill @s
execute in minecraft:overworld as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run kill @s
execute in minecraft:the_nether as @e[tag=sd.fb.ash,distance=0..] at @s run kill @s
execute in minecraft:the_nether as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run kill @s
execute in minecraft:the_end as @e[tag=sd.fb.ash,distance=0..] at @s run kill @s
execute in minecraft:the_end as @e[tag=sd.fb.ash_cloud,distance=0..] at @s run kill @s
execute in minecraft:overworld run kill @e[tag=sd.fb.fx,distance=0..]
execute in minecraft:the_nether run kill @e[tag=sd.fb.fx,distance=0..]
execute in minecraft:the_end run kill @e[tag=sd.fb.fx,distance=0..]
