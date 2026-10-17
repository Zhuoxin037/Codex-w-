scoreboard players add @s sdbf.age 1
execute if score @s sdbf.state matches 2 run function sweetdream:boss/fireaxe/action/chop
execute if score @s sdbf.state matches 3 run function sweetdream:boss/fireaxe/action/sweep
execute if score @s sdbf.state matches 4 run function sweetdream:boss/fireaxe/action/jump
execute if score @s sdbf.state matches 5 run function sweetdream:boss/fireaxe/action/dash
execute if score @s sdbf.state matches 6 run function sweetdream:boss/fireaxe/action/short
execute if score @s sdbf.state matches 7 run function sweetdream:boss/fireaxe/action/recover
execute if score @s sdbf.state matches 10 run function sweetdream:boss/fireaxe/phase/tick
execute if score @s sdbf.state matches 11 run function sweetdream:boss/fireaxe/action/combo_jump
execute if score @s sdbf.state matches 12 run function sweetdream:boss/fireaxe/action/combo_dash
