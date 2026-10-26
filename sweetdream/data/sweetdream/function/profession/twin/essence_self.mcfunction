scoreboard players add @s zx.j_ess 1
scoreboard players set #jesscap zx.meta 5
execute if score @s zx.j_aw matches 1 run scoreboard players set #jesscap zx.meta 8
execute if score @s zx.j_ess > #jesscap zx.meta run scoreboard players operation @s zx.j_ess = #jesscap zx.meta
execute if score @s zx.j_il_t matches 1.. run function sweetdream:profession/twin/essence_echo
