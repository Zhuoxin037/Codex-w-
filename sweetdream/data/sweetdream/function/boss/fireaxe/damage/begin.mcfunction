scoreboard players operation @s sdbf.oldhp = @s sdbf.pendhp
scoreboard players set @s sdbf.nexthp 0
$scoreboard players set @s sdbf.dmg $(base)
scoreboard players operation @s sdbf.extra = @s sdbf.oldhp
scoreboard players operation @s sdbf.extra /= #10 sdbf.num
execute if score @s sdbf.phase matches 3 run scoreboard players operation @s sdbf.extra = @s sdbf.oldhp
execute if score @s sdbf.phase matches 3 run scoreboard players operation @s sdbf.extra /= #5 sdbf.num
scoreboard players operation @s sdbf.dmg *= #1000 sdbf.num
scoreboard players operation @s sdbf.dmg += @s sdbf.extra
execute store result storage sweetdream:fireaxe hit.amount double 0.001 run scoreboard players get @s sdbf.dmg
execute as @e[tag=sd.fb.hit,distance=0..] at @s run function sweetdream:boss/fireaxe/damage/target
scoreboard players operation @s sdbf.pendhp = @s sdbf.nexthp
