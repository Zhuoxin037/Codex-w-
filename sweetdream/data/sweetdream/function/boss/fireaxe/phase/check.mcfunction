execute unless score @s sdbf.phase matches 1..3 run scoreboard players set @s sdbf.phase 1
execute unless score @s sdbf.phase matches 2 if entity @s[tag=sd.fb.transition] run function sweetdream:boss/fireaxe/phase/clear
execute if score @s sdbf.phase matches 1 if score @s sdbf.hp1000 matches ..500000 if score @s sdbf.state matches ..1 unless score @s sdbf.fall matches 1.. run function sweetdream:boss/fireaxe/phase/begin
