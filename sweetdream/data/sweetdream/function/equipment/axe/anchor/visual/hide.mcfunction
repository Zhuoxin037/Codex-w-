function sweetdream:equipment/axe/anchor/visual/model_sync
scoreboard players set #av_old zx.meta -1
execute if score @s zx.av_hand matches 0 if data entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] store result score #av_old zx.meta run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] 1
execute if score @s zx.av_hand matches 1 if data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] store result score #av_old zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] 1
execute if score #av_old zx.meta matches 500 run return 0
scoreboard players set #av_pose zx.meta 500
function sweetdream:equipment/axe/anchor/visual/set_hand
