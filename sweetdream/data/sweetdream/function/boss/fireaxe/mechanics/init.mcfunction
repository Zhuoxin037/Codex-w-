data modify entity @s CustomName set value {text:"NauseAxe"}
data modify entity @s CustomNameVisible set value 0b
execute unless score @s sdbf.pendhp = @s sdbf.pendhp run scoreboard players set @s sdbf.pendhp 0
execute unless score @s sdbf.dtime = @s sdbf.dtime run scoreboard players set @s sdbf.dtime 0
execute unless score @s sdbf.sprint = @s sdbf.sprint run scoreboard players set @s sdbf.sprint 0
function sweetdream:boss/fireaxe/mechanics/armor
