scoreboard players add @s zx.el_clock 1
execute if score @s zx.el_clock matches 80.. run scoreboard players set @s zx.el_clock 0
execute if score @s zx.el_attack matches 0..22 run scoreboard players add @s zx.el_attack 1
execute if score @s zx.el_attack matches 23.. run scoreboard players set @s zx.el_clock 0
execute if score @s zx.el_attack matches 23.. run scoreboard players set @s zx.el_attack -1
execute if score @s zx.el_state matches 1 run scoreboard players add @s zx.el_time 1
execute if score @s zx.el_state matches 3 run scoreboard players add @s zx.el_time 1
execute if score @s zx.el_state matches 1 if score @s zx.el_time matches 17.. run scoreboard players set @s zx.el_clock 0
execute if score @s zx.el_state matches 1 if score @s zx.el_time matches 17.. run scoreboard players set @s zx.el_state 2
execute if score @s zx.el_state matches 3 if score @s zx.el_time matches 17.. run scoreboard players set @s zx.el_clock 0
execute if score @s zx.el_state matches 3 if score @s zx.el_time matches 17.. run scoreboard players set @s zx.el_state 0
execute if score @s zx.el_state matches 0 if score @s zx.el_attack matches -2 run scoreboard players set @s zx.el_attack 0
