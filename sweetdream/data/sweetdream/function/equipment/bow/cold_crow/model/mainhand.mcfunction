# 先比较组件，外观不变时不写入物品，避免干扰原版装填。
scoreboard players add @s zx.cc_ice 0
scoreboard players set #ice zx.cc_vis 0
scoreboard players operation #ice zx.cc_vis = @s zx.cc_ice
execute if score #ice zx.cc_vis matches ..-1 run scoreboard players set #ice zx.cc_vis 0
execute if score #ice zx.cc_vis matches 4.. run scoreboard players set #ice zx.cc_vis 3
scoreboard players set #frame zx.cc_vis 0
execute if score @s zx.cc_fx matches 1..16 run scoreboard players operation #frame zx.cc_vis = @s zx.cc_fx
execute if score @s zx.cc_fx matches 1..16 run scoreboard players add #frame zx.cc_vis 1
execute if score @s zx.cc_fx matches 1..16 run scoreboard players operation #frame zx.cc_vis /= #two zx.cc_vis
scoreboard players set #oldice zx.cc_vis -1
scoreboard players set #oldframe zx.cc_vis -1
execute if data entity @s SelectedItem.components."minecraft:custom_model_data".floats[0] store result score #oldice zx.cc_vis run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[0] 1
execute if data entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] store result score #oldframe zx.cc_vis run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[1] 1
execute if items entity @s weapon.mainhand *[minecraft:item_model="coldcrow:crossbow"] if score #oldice zx.cc_vis = #ice zx.cc_vis if score #oldframe zx.cc_vis = #frame zx.cc_vis run return 0
item modify entity @s weapon.mainhand sweetdream:cold_crow_visual
