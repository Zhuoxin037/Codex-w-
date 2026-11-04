scoreboard players set #native_active zx.meta 0
execute if data storage zx:config damage_text{enabled:1b} if entity @a run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run scoreboard players set #native_active zx.meta 1
execute as @a if items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run scoreboard players set #native_active zx.meta 1
scoreboard players set #s2_veil_watch zx.meta 0
execute as @a[scores={zx.job=4,zx.j_form=0,zx.j_reborn=1..}] if items entity @s armor.head *[minecraft:custom_data~{zx:["rebirth_veil"]}] run scoreboard players set #s2_veil_watch zx.meta 1
execute if score #s2_veil_watch zx.meta matches 1 run scoreboard players set #native_active zx.meta 1
execute unless score #native_active zx.meta matches 1 run return 0
execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,distance=0..] unless score @s zx.native_gen = #native_gen zx.meta run tag @s remove zx.native_known
execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,tag=!zx.native_known,distance=0..,limit=24] if data entity @s Health run function sweetdream:internal/native/enroll
execute if score #s2_veil_watch zx.meta matches 1 in minecraft:overworld as @e[tag=zx.native_known,type=!#sweetdream:no_damage,distance=0..] unless data entity @s {HurtTime:10s} run function sweetdream:internal/native/stamp
execute if score #s2_veil_watch zx.meta matches 1 in minecraft:the_nether as @e[tag=zx.native_known,type=!#sweetdream:no_damage,distance=0..] unless data entity @s {HurtTime:10s} run function sweetdream:internal/native/stamp
execute if score #s2_veil_watch zx.meta matches 1 in minecraft:the_end as @e[tag=zx.native_known,type=!#sweetdream:no_damage,distance=0..] unless data entity @s {HurtTime:10s} run function sweetdream:internal/native/stamp
