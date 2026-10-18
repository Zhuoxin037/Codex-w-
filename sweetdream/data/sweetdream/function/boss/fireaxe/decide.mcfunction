execute unless entity @e[tag=sd.fb.target,distance=0..] run return run function sweetdream:boss/fireaxe/idle
execute if score @s sdbf.rest matches 1.. run return run function sweetdream:boss/fireaxe/idle
function sweetdream:boss/fireaxe/face
execute if entity @e[tag=sd.fb.target,distance=..3.5] run return run function sweetdream:boss/fireaxe/melee_choose
execute if entity @e[tag=sd.fb.target,distance=12.0001..30] if score @s sdbf.jumpcd matches 0 run return run function sweetdream:boss/fireaxe/start/jump
execute if entity @e[tag=sd.fb.target,distance=3.5..30] if score @s sdbf.dashcd matches 0 run return run function sweetdream:boss/fireaxe/start/dash
execute at @s run function sweetdream:boss/fireaxe/walk
