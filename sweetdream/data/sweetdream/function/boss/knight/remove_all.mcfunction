execute in minecraft:overworld as @e[tag=sd.kn.rig,distance=0..] at @s run function sweetdream:boss/knight/remove_rig
execute in minecraft:overworld run kill @e[tag=sd.kn.body,distance=0..]
execute in minecraft:overworld run kill @e[tag=sd.kn.fx,distance=0..]
execute in minecraft:the_nether as @e[tag=sd.kn.rig,distance=0..] at @s run function sweetdream:boss/knight/remove_rig
execute in minecraft:the_nether run kill @e[tag=sd.kn.body,distance=0..]
execute in minecraft:the_nether run kill @e[tag=sd.kn.fx,distance=0..]
execute in minecraft:the_end as @e[tag=sd.kn.rig,distance=0..] at @s run function sweetdream:boss/knight/remove_rig
execute in minecraft:the_end run kill @e[tag=sd.kn.body,distance=0..]
execute in minecraft:the_end run kill @e[tag=sd.kn.fx,distance=0..]

execute in minecraft:overworld as @e[tag=sd.kn.shadow,distance=0..] at @s run function sweetdream:boss/knight/shadow/end
execute in minecraft:overworld run kill @e[tag=sd.kn.shadow_bone,distance=0..]
execute in minecraft:the_nether as @e[tag=sd.kn.shadow,distance=0..] at @s run function sweetdream:boss/knight/shadow/end
execute in minecraft:the_nether run kill @e[tag=sd.kn.shadow_bone,distance=0..]
execute in minecraft:the_end as @e[tag=sd.kn.shadow,distance=0..] at @s run function sweetdream:boss/knight/shadow/end
execute in minecraft:the_end run kill @e[tag=sd.kn.shadow_bone,distance=0..]
