# 平时不写物品，只有施法玩家进入帧驱动。
execute as @a[tag=zx.sd_sweep] at @s run function sweetdream:equipment/sword/sickle_dreams/sweep/player
# 捡回、换到副手或备份架子返还的过期帧，恢复默认外观；掉落/背包本来就是静态。
execute as @a[tag=!zx.sd_sweep] if data entity @s SelectedItem.components."minecraft:custom_data".sd_sweep unless items entity @s weapon.mainhand *[minecraft:item_model="dreamscythe:sickle"] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run item modify entity @s weapon.mainhand sweetdream:sickle_sweep_reset
execute as @a if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] unless items entity @s weapon.offhand *[minecraft:item_model="dreamscythe:sickle"] if data entity @s Inventory[{Slot:-106b}].components."minecraft:custom_data".sd_sweep run item modify entity @s weapon.offhand sweetdream:sickle_sweep_reset
