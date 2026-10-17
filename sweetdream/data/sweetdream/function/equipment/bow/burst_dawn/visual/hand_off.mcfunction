execute unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:crossbow_burst_dawn"] run item modify entity @s weapon.offhand sweetdream:burst_dawn_visual/model
execute unless data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[0] run item modify entity @s weapon.offhand sweetdream:burst_dawn_visual/seed
scoreboard players set #bv_old zx.meta -1
execute store result score #bv_old zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1]
execute unless score #bv_old zx.meta = #bv_pose zx.meta run item modify entity @s weapon.offhand sweetdream:burst_dawn_visual/hand
