scoreboard players set #av_old zx.meta -1
execute if data entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] store result score #av_old zx.meta run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] 1
execute if score #av_old zx.meta = #av_pose zx.meta run return 0
execute unless data entity @s SelectedItem.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.mainhand sweetdream:anchor_visual/seed
item modify entity @s weapon.mainhand sweetdream:anchor_visual/frame
