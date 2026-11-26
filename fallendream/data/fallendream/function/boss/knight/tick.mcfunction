execute in minecraft:overworld as @e[tag=sd.kn.body,distance=0..] at @s run function fallendream:boss/knight/orphan_check
execute in minecraft:overworld as @e[tag=sd.kn.wave,distance=0..] at @s run function fallendream:boss/knight/wave/tick
execute in minecraft:overworld as @e[tag=sd.kn.trace,distance=0..] at @s run function fallendream:boss/knight/echo/tick
execute in minecraft:overworld as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/tick
execute in minecraft:the_nether as @e[tag=sd.kn.body,distance=0..] at @s run function fallendream:boss/knight/orphan_check
execute in minecraft:the_nether as @e[tag=sd.kn.wave,distance=0..] at @s run function fallendream:boss/knight/wave/tick
execute in minecraft:the_nether as @e[tag=sd.kn.trace,distance=0..] at @s run function fallendream:boss/knight/echo/tick
execute in minecraft:the_nether as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/tick
execute in minecraft:the_end as @e[tag=sd.kn.body,distance=0..] at @s run function fallendream:boss/knight/orphan_check
execute in minecraft:the_end as @e[tag=sd.kn.wave,distance=0..] at @s run function fallendream:boss/knight/wave/tick
execute in minecraft:the_end as @e[tag=sd.kn.trace,distance=0..] at @s run function fallendream:boss/knight/echo/tick
execute in minecraft:the_end as @e[tag=sd.kn.shadow,distance=0..] at @s run function fallendream:boss/knight/shadow/tick
scoreboard players add #bars sdk.step 1
execute if score #bars sdk.step matches 20.. run function fallendream:boss/knight/bar_watch
