execute in minecraft:overworld as @e[tag=sd.hk.body,distance=0..] at @s run function sweetdream:boss/husk/orphan
execute in minecraft:the_nether as @e[tag=sd.hk.body,distance=0..] at @s run function sweetdream:boss/husk/orphan
execute in minecraft:the_end as @e[tag=sd.hk.body,distance=0..] at @s run function sweetdream:boss/husk/orphan
scoreboard players add #bars sdh.bar 1
execute if score #bars sdh.bar matches 20.. run function sweetdream:boss/husk/bar/watch
