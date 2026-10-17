execute unless score @s sdbf.jstep matches 100..280 run scoreboard players set @s sdbf.jstep 200
execute store result storage sweetdream:fireaxe combo_move.step double 0.001 run scoreboard players get @s sdbf.jstep
function sweetdream:boss/fireaxe/rush_air with storage sweetdream:fireaxe combo_move
