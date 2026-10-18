scoreboard players operation @s sdbf.dtime = @s sdbf.age
execute if score @s sdbf.dtime matches 301.. run scoreboard players set @s sdbf.dtime 300
scoreboard players operation @s sdbf.dspeed = @s sdbf.dtime
scoreboard players operation @s sdbf.dspeed *= #250000 sdbf.num
scoreboard players operation @s sdbf.dspeed /= #300 sdbf.num
scoreboard players add @s sdbf.dspeed 250000
execute if score @s sdbf.dspeed matches 375000.. unless score @s sdbf.sprint matches 1 run function sweetdream:boss/fireaxe/dash/sprint_begin
execute store result storage sweetdream:fireaxe dash_move.step double 0.000001 run scoreboard players get @s sdbf.dspeed
execute if score @s sdbf.blocked matches 0 run function sweetdream:boss/fireaxe/rush_step with storage sweetdream:fireaxe dash_move
