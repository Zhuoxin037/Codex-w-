tag @s add sd.floor_seen
execute unless entity @s[tag=sd.floor_run] in minecraft:overworld run tp @s -48.5 90 48.5 90 0
execute unless entity @s[tag=sd.floor_run] run function sweetdream_floor:lobby/menu
