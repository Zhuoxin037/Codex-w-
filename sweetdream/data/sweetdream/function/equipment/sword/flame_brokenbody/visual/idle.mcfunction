# 非施法状态的现有武器兜底复位，不修改其他物品，不触碰已有floats[0]。
scoreboard players set #fb_idle zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] if data entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] store result score #fb_idle zx.meta run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] 1
execute if score #fb_idle zx.meta matches 100.. run item modify entity @s weapon.mainhand sweetdream:flame_cast/idle
scoreboard players set #fb_idle zx.meta 0
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] if data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] store result score #fb_idle zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] 1
execute if score #fb_idle zx.meta matches 100.. run item modify entity @s weapon.offhand sweetdream:flame_cast/idle
