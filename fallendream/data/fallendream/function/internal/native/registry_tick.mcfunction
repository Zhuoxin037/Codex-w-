scoreboard players set #native_active zx.meta 0
execute unless entity @a run return 0
scoreboard players set #native_active zx.meta 1
execute in minecraft:overworld as @e[type=!#fallendream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:overworld as @e[type=!#fallendream:no_damage,tag=!zx.native_known,distance=0..] if data entity @s Health run function fallendream:internal/native/enroll
execute in minecraft:the_nether as @e[type=!#fallendream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_nether as @e[type=!#fallendream:no_damage,tag=!zx.native_known,distance=0..] if data entity @s Health run function fallendream:internal/native/enroll
execute in minecraft:the_end as @e[type=!#fallendream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_end as @e[type=!#fallendream:no_damage,tag=!zx.native_known,distance=0..] if data entity @s Health run function fallendream:internal/native/enroll
execute in minecraft:overworld as @e[tag=zx.native_known,type=!#fallendream:no_damage,distance=0..] run function fallendream:internal/native/stamp
execute in minecraft:the_nether as @e[tag=zx.native_known,type=!#fallendream:no_damage,distance=0..] run function fallendream:internal/native/stamp
execute in minecraft:the_end as @e[tag=zx.native_known,type=!#fallendream:no_damage,distance=0..] run function fallendream:internal/native/stamp
