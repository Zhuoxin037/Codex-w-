scoreboard players set @s zx.av_hand 0
scoreboard players set @s zx.av_slot 0
execute unless items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["anchor"]}] if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] run scoreboard players set @s zx.av_hand 1
execute if score @s zx.av_hand matches 0 store result score @s zx.av_slot run data get entity @s SelectedItemSlot
function sweetdream:equipment/axe/anchor/visual/dimension
scoreboard players operation @s zx.av_dim = #av_dim zx.meta
scoreboard players set @s zx.av_life 0
tag @s add zx.av_cast
function sweetdream:equipment/axe/anchor/visual/model_sync
