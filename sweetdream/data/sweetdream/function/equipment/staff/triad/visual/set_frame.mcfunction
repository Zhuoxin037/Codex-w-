execute if score @s zx.tv_hand matches 0 unless data entity @s SelectedItem.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.mainhand sweetdream:triad_visual/seed
execute if score @s zx.tv_hand matches 1 unless data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.offhand sweetdream:triad_visual/seed
execute if score @s zx.tv_hand matches 0 run item modify entity @s weapon.mainhand sweetdream:triad_visual/frame
execute if score @s zx.tv_hand matches 1 run item modify entity @s weapon.offhand sweetdream:triad_visual/frame
