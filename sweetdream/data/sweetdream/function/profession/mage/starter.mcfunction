scoreboard players add @s zx.j_f_given 0
execute if score @s zx.j_f_given matches 1 run return 0
execute if score @s zx.j_f_given matches 3 run return 0
function sweetdream:equipment/tool/grimoire/give
function sweetdream:equipment/staff/mana_crystal/give
scoreboard players add @s zx.j_f_given 1
