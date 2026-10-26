execute unless score @s zx.j_init matches 1 run function sweetdream:profession/stats
execute if score @s zx.deaths matches 1.. unless score @s zx.j_lastdeath = @s zx.deaths run function sweetdream:profession/death
execute if score @s zx.job matches 1 run function sweetdream:profession/mage/tick
execute if score @s zx.job matches 2 run function sweetdream:profession/berserker/apply
execute if score @s zx.job matches 4 run function sweetdream:profession/twin/tick
execute if score @s zx.job matches 4 if score @s zx.j_form matches 0 run scoreboard players operation @s zx.j_dlast = @s zx.j_dmg

function sweetdream:profession/weapon_guard
