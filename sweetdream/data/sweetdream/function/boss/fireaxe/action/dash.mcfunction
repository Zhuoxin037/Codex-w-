execute unless score @s sdbf.dphase matches 0..2 run function sweetdream:boss/fireaxe/dash/migrate
execute if score @s sdbf.dphase matches 2 run return run function sweetdream:boss/fireaxe/dash/strike_tick
execute unless entity @e[tag=sd.fb.target,distance=..24] run return run function sweetdream:boss/fireaxe/abort_dash
execute if score @s sdbf.fall matches 1.. run return 0
function sweetdream:boss/fireaxe/face
execute at @s if entity @e[tag=sd.fb.target,distance=..2.6] run return run function sweetdream:boss/fireaxe/dash/strike_begin
execute if score @s sdbf.dphase matches 0 if score @s sdbf.age matches ..9 at @s run function sweetdream:boss/fireaxe/motion/short
execute unless score @s sdbf.state matches 5 run return 0
execute if score @s sdbf.age matches ..9 run return 0
execute if score @s sdbf.dphase matches 0 run function sweetdream:boss/fireaxe/dash/loop_begin
execute at @s run function sweetdream:boss/fireaxe/motion/dash
