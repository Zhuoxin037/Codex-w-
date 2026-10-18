scoreboard players add @s sdbf.fxage 1
execute if score @s sdbf.fxland matches 1.. run scoreboard players add @s sdbf.fxland 1
execute if score @s sdbf.fxland matches 5.. run return run kill @s
execute if score @s sdbf.fxland matches 1.. run return 0
execute if score @s sdbf.fxage matches 120.. run return run kill @s
execute positioned ^ ^ ^0.085 run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 1 at @s positioned ~ ~0.45500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 2 at @s positioned ~ ~0.38500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 3 at @s positioned ~ ~0.31500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 4 at @s positioned ~ ~0.24500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 5 at @s positioned ~ ~0.17500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 6 at @s positioned ~ ~0.10500 ~ run tp @s ~ ~ ~
execute if score @s sdbf.fxage matches 7 at @s positioned ~ ~0.03500 ~ run tp @s ~ ~ ~
scoreboard players set @s sdbf.fxsteps 14
execute if score @s sdbf.fxage matches 8 run scoreboard players set @s sdbf.fxsteps 1
execute if score @s sdbf.fxage matches 9 run scoreboard players set @s sdbf.fxsteps 3
execute if score @s sdbf.fxage matches 10 run scoreboard players set @s sdbf.fxsteps 5
execute if score @s sdbf.fxage matches 11 run scoreboard players set @s sdbf.fxsteps 7
execute if score @s sdbf.fxage matches 12 run scoreboard players set @s sdbf.fxsteps 8
execute if score @s sdbf.fxage matches 13 run scoreboard players set @s sdbf.fxsteps 10
execute if score @s sdbf.fxage matches 14 run scoreboard players set @s sdbf.fxsteps 12
execute if score @s sdbf.fxage matches 8.. at @s run function sweetdream:boss/fireaxe/fx/chunk_fall
