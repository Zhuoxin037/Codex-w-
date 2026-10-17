execute unless score @s sdbf.cmask matches 0 run return 0
scoreboard players set @s sdbf.cmask 1
execute at @s run function sweetdream:boss/fireaxe/hit/dash
