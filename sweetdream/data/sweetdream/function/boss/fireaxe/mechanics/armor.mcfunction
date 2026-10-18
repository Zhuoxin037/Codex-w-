attribute @s minecraft:armor base set 6.5
attribute @s minecraft:armor_toughness base set 20
execute if score @s sdbf.phase matches 3 run attribute @s minecraft:armor base set 9
scoreboard players operation @s sdbf.armorphase = @s sdbf.phase
