# 仅读原版物品NBT；回写由 item modify 完成，保留名字、附魔和强化数据。
scoreboard players set #sr_old zx.srv_frame -999
execute store result score #sr_old zx.srv_frame run data get entity @s Inventory[{Slot:-106b}].components."minecraft:custom_model_data".floats[0]
execute if score #sr_old zx.srv_frame = #sr_frame zx.srv_frame if items entity @s weapon.offhand *[minecraft:item_model="sweetdream:sacred_relic"] run return 0
item modify entity @s weapon.offhand sweetdream:sacred_relic_visual
