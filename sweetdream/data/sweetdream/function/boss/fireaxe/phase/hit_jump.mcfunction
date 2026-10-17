execute unless score @s sdbf.cmask matches 1 run return 0
scoreboard players set @s sdbf.cmask 2
execute at @s run function sweetdream:boss/fireaxe/hit/jump
