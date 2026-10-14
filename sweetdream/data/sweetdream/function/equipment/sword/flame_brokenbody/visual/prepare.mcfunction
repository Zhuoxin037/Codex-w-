# 尚无 floats[0] 的旧武器先补占位；随后只修改 floats[1]，不清已有其他通道。
execute if score @s zx.fb_hand matches 0 unless data entity @s SelectedItem.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.mainhand sweetdream:flame_cast/seed
execute if score @s zx.fb_hand matches 1 unless data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.offhand sweetdream:flame_cast/seed
