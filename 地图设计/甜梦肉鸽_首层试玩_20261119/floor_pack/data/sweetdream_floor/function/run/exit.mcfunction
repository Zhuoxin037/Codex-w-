execute if entity @s[tag=zx.rg_active] run function sweetdream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_wait] run function sweetdream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_prep] run function sweetdream:rogue/prototype/exit
execute at @s run function sweetdream_floor:run/recycle_weapons
tag @s remove sd.floor_run
function sweetdream_floor:run/orphan
execute in minecraft:overworld run tp @s -48.5 90 48.5 90 0
function sweetdream_floor:lobby/menu
