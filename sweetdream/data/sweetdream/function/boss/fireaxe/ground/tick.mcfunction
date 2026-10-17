# The approved jump has its own vertical track; do not apply gravity twice.
execute if score @s sdbf.state matches 4 run return 0
execute if score @s sdbf.state matches 11 run return 0
execute if entity @s[nbt={NoGravity:1b}] run data modify entity @s NoGravity set value 0b
execute unless score @s sdbf.fall = @s sdbf.fall run scoreboard players set @s sdbf.fall 0
scoreboard players add @s sdbf.fall 2
execute if score @s sdbf.fall matches 41.. run scoreboard players set @s sdbf.fall 40
scoreboard players operation @s sdbf.fallsteps = @s sdbf.fall
execute at @s run function sweetdream:boss/fireaxe/ground/drop
