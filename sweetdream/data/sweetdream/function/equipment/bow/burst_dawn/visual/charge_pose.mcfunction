scoreboard players set #bv_q zx.meta 0
execute store result score #bv_q zx.meta run data get entity @s SelectedItem.components."minecraft:enchantments"."minecraft:quick_charge"
scoreboard players set #bv_five zx.meta 5
scoreboard players operation #bv_q zx.meta *= #bv_five zx.meta
scoreboard players set #bv_duration zx.meta 25
scoreboard players operation #bv_duration zx.meta -= #bv_q zx.meta
execute if score #bv_duration zx.meta matches ..4 run scoreboard players set #bv_duration zx.meta 5
scoreboard players operation #bv_pose zx.meta = @s zx.bv_charge
scoreboard players set #bv_twelve zx.meta 12
scoreboard players operation #bv_pose zx.meta *= #bv_twelve zx.meta
scoreboard players operation #bv_pose zx.meta /= #bv_duration zx.meta
execute if score #bv_pose zx.meta matches 13.. run scoreboard players set #bv_pose zx.meta 12
scoreboard players add #bv_pose zx.meta 100
