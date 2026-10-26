scoreboard players set #native_active zx.meta 0
execute as @a if items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run scoreboard players set #native_active zx.meta 1
execute unless score #native_active zx.meta matches 1 run return 0
execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
