scoreboard players add @s sdbf.fxage 1
execute if score @s sdbf.fxage matches 10 run data modify entity @s item.components."minecraft:item_model" set value "sweetdream_boss:blueprint/reconstruction/fx/crack_1"
execute if score @s sdbf.fxage matches 15 run data modify entity @s item.components."minecraft:item_model" set value "sweetdream_boss:blueprint/reconstruction/fx/crack_2"
execute if score @s sdbf.fxage matches 20.. run kill @s
