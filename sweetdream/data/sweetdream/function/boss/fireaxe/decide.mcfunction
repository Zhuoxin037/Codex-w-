execute unless entity @e[tag=sd.fb.target,distance=0..] run return run function sweetdream:boss/fireaxe/idle
execute if score @s sdbf.rest matches 1.. run return run function sweetdream:boss/fireaxe/idle
function sweetdream:boss/fireaxe/face
execute if entity @e[tag=sd.fb.target,distance=..3.5] run return run function sweetdream:boss/fireaxe/melee_choose
execute if score @s sdbf.dashcd matches 0 if entity @e[tag=sd.fb.target,distance=6..12] run return run function sweetdream:boss/fireaxe/start/dash
execute if score @s sdbf.jumpcd matches 0 if entity @e[tag=sd.fb.target,distance=3.5..6] run return run function sweetdream:boss/fireaxe/start/jump
execute if score @s sdbf.shortcd matches 0 if entity @e[tag=sd.fb.target,distance=3.5..6] run return run function sweetdream:boss/fireaxe/start/short
execute at @s run function sweetdream:boss/fireaxe/walk
