$execute if score @s sdbf.state matches 5 run function sweetdream:boss/fireaxe/move {step:$(step),ground:0}
$execute unless score @s sdbf.state matches 5 run function sweetdream:boss/fireaxe/move {step:$(step),ground:1}
execute if score @s sdbf.moved matches 0 run scoreboard players set @s sdbf.blocked 1
execute if score @s sdbf.moved matches 0 run playsound minecraft:block.netherite_block.hit hostile @a[distance=..24] ~ ~ ~ 0.8 0.7
execute if score @s sdbf.moved matches 0 run function sweetdream:boss/fireaxe/abort_dash
