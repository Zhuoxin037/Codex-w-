execute store result score @s sdbf.choice run random value 0..2
execute if score @s sdbf.choice matches 2 if score @s sdbf.jumpcd matches 0 run return run function sweetdream:boss/fireaxe/start/combo_jump
execute if score @s sdbf.choice matches 0 run return run function sweetdream:boss/fireaxe/start/chop
function sweetdream:boss/fireaxe/start/sweep
