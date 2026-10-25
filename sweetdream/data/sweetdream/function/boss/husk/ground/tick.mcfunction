data modify entity @s NoGravity set value 0b
scoreboard players add @s sdh.fall 2
execute if score @s sdh.fall matches 41.. run scoreboard players set @s sdh.fall 40
scoreboard players operation @s sdh.fallsteps = @s sdh.fall
execute at @s run function sweetdream:boss/husk/ground/drop
