scoreboard players set @s sdbf.ltotal 0
scoreboard players set @s sdbf.lbudget 0
$scoreboard players set @s sdbf.lticks $(ticks)
execute if entity @e[tag=sd.fb.target,distance=..30] at @s rotated ~ 0 run function sweetdream:boss/fireaxe/leap/measure
