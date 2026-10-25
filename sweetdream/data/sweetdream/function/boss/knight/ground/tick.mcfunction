data modify entity @s NoGravity set value 0b
scoreboard players add @s sdk.fall 2
execute if score @s sdk.fall matches 41.. run scoreboard players set @s sdk.fall 40
scoreboard players operation @s sdk.fallsteps = @s sdk.fall
execute at @s run function sweetdream:boss/knight/ground/drop
