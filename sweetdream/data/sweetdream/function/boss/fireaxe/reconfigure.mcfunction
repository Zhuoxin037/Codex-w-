attribute @s minecraft:scale base set 2.25
data modify entity @s NoAI set value 1b
data modify entity @s CustomNameVisible set value 0b
function sweetdream:boss/fireaxe/visual/carrier_label
execute unless score @s sdbf.last_hp = @s sdbf.last_hp store result score @s sdbf.last_hp run data get entity @s Health 1000
function sweetdream:boss/fireaxe/mechanics/init
