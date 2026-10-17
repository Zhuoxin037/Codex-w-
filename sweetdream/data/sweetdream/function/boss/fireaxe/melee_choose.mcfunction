execute if score @s sdbf.phase matches 3 run return run function sweetdream:boss/fireaxe/phase/melee
execute store result score @s sdbf.choice run random value 0..1
execute if score @s sdbf.choice matches 0 run return run function sweetdream:boss/fireaxe/start/chop
function sweetdream:boss/fireaxe/start/sweep
