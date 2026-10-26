execute unless items entity @s weapon.mainhand *[custom_data~{zx:["illusion"]}] run return 0
execute if score @s zx.j_hurt_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.j_hurt_lt = #now manacore.meta
function sweetdream:profession/twin/path
