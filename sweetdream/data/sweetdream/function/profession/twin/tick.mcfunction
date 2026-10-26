execute if score @s zx.j_reborn matches 1.. run scoreboard players remove @s zx.j_reborn 1
execute if score @s zx.j_reborn matches 0 run function sweetdream:profession/twin/reborn_due
execute if score @s zx.j_form matches 1 run function sweetdream:profession/twin/control
execute if score @s zx.j_il_t matches 1.. run scoreboard players remove @s zx.j_il_t 1
execute if score @s zx.j_empath matches 1.. run scoreboard players remove @s zx.j_empath 1
execute if score @s zx.j_host_t matches 1.. run function sweetdream:profession/twin/host_tick
