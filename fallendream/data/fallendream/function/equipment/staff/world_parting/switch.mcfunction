scoreboard players add @s zx.wp_switch 0
execute if score @s zx.wp_switch matches 6.. run return fail
execute if score @s zx.j_form matches 0 if score @s zx.j_reborn matches 1.. run return fail
scoreboard players set #phase_form zx.meta 0
execute if score @s zx.j_form matches 1 run scoreboard players set #phase_form zx.meta 1
execute if score #phase_form zx.meta matches 1 run function fallendream:profession/twin/return
execute if score #phase_form zx.meta matches 0 run function fallendream:profession/twin/enter
scoreboard players add @s zx.wp_switch 1
