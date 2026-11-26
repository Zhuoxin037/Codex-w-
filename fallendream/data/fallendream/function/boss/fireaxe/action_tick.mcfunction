scoreboard players add @s sdbf.age 1
execute if score @s sdbf.state matches 2 run function fallendream:boss/fireaxe/action/chop
execute if score @s sdbf.state matches 3 run function fallendream:boss/fireaxe/action/sweep
execute if score @s sdbf.state matches 4 run function fallendream:boss/fireaxe/action/jump
execute if score @s sdbf.state matches 5 run function fallendream:boss/fireaxe/action/dash
execute if score @s sdbf.state matches 6 run function fallendream:boss/fireaxe/action/short
execute if score @s sdbf.state matches 7 run function fallendream:boss/fireaxe/action/recover
execute if score @s sdbf.state matches 10 run function fallendream:boss/fireaxe/phase/tick
execute if score @s sdbf.state matches 11 run function fallendream:boss/fireaxe/action/combo_jump
execute if score @s sdbf.state matches 12 run function fallendream:boss/fireaxe/action/combo_dash
