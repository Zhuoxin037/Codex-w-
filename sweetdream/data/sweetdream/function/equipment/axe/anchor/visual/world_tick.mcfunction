execute unless data entity @s item.components."minecraft:custom_data".zx_an run return run kill @s
scoreboard players add @s zx.av_life 1
execute if score @s zx.av_life matches 70.. run return run kill @s
function sweetdream:equipment/axe/anchor/visual/world_owner with entity @s item.components."minecraft:custom_data".zx_an
