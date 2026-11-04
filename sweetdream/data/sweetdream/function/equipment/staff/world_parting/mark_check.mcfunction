scoreboard players add @s zx.wp_red 0
scoreboard players add @s zx.wp_white 0
scoreboard players add @s zx.wp_gate 0
execute if score @s zx.wp_red > #now manacore.meta if score @s zx.wp_white > #now manacore.meta unless score @s zx.wp_gate > #now manacore.meta run function sweetdream:equipment/staff/world_parting/trigger
