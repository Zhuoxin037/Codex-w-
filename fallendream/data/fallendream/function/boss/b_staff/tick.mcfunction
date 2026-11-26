scoreboard players add #sweep bs.bar 1
execute if score #sweep bs.bar matches 20.. run function fallendream:boss/b_staff/bar/sweep
execute in minecraft:overworld as @e[tag=sd.bs.bone,tag=sd.bs.unbound,distance=0..] at @s run function fallendream:boss/b_staff/part/bind
execute in minecraft:overworld as @e[tag=sd.bs.rig,distance=0..] at @s run function fallendream:boss/b_staff/rig_tick
execute in minecraft:overworld as @e[tag=sd.bs.fx,distance=0..] at @s run function fallendream:boss/b_staff/fx/tick
execute in minecraft:overworld as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/orphan
execute in minecraft:the_nether as @e[tag=sd.bs.bone,tag=sd.bs.unbound,distance=0..] at @s run function fallendream:boss/b_staff/part/bind
execute in minecraft:the_nether as @e[tag=sd.bs.rig,distance=0..] at @s run function fallendream:boss/b_staff/rig_tick
execute in minecraft:the_nether as @e[tag=sd.bs.fx,distance=0..] at @s run function fallendream:boss/b_staff/fx/tick
execute in minecraft:the_nether as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/orphan
execute in minecraft:the_end as @e[tag=sd.bs.bone,tag=sd.bs.unbound,distance=0..] at @s run function fallendream:boss/b_staff/part/bind
execute in minecraft:the_end as @e[tag=sd.bs.rig,distance=0..] at @s run function fallendream:boss/b_staff/rig_tick
execute in minecraft:the_end as @e[tag=sd.bs.fx,distance=0..] at @s run function fallendream:boss/b_staff/fx/tick
execute in minecraft:the_end as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/orphan
execute in fallendream:rogue_preview as @e[tag=sd.bs.bone,tag=sd.bs.unbound,distance=0..] at @s run function fallendream:boss/b_staff/part/bind
execute in fallendream:rogue_preview as @e[tag=sd.bs.rig,distance=0..] at @s run function fallendream:boss/b_staff/rig_tick
execute in fallendream:rogue_preview as @e[tag=sd.bs.fx,distance=0..] at @s run function fallendream:boss/b_staff/fx/tick
execute in fallendream:rogue_preview as @e[tag=sd.bs.body,distance=0..] at @s run function fallendream:boss/b_staff/orphan
