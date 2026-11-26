execute if entity @s[tag=sd.floor_run] run return run function sweetdream_floor:run/exit
execute if entity @s[tag=sd.floor_tutorial] run function sweetdream_floor:tutorial/clear
tag @s remove sd.floor_tutorial
execute in minecraft:overworld run tp @s -48.5 90 48.5 90 0
function sweetdream_floor:lobby/menu
