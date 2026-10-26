execute if score #bc_zone zx.meta matches 1 run scoreboard players add @s zx.bc_near 1
execute if score #bc_zone zx.meta matches 0 run scoreboard players add @s zx.bc_far 1
execute if score @s zx.bc_near matches 60.. run scoreboard players set #bc_convert zx.meta 1
execute if score @s zx.bc_far matches 100.. run scoreboard players set #bc_convert zx.meta 1

execute if score #bc_convert zx.meta matches 1 run scoreboard players set @s zx.bc_near 0
execute if score #bc_convert zx.meta matches 1 run scoreboard players set @s zx.bc_far 0
