data modify entity @s NoGravity set value 0b
scoreboard players set @s sdbf.rest 24
execute if score @s sdbf.phase matches 3 run scoreboard players set @s sdbf.rest 20
function sweetdream:boss/fireaxe/idle
