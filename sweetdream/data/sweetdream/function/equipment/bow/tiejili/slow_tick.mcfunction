# Union all fields before managing effects: overlapping fields cannot clear one another.
tag @e[tag=zx.tjl_inside] remove zx.tjl_inside
execute as @e[type=marker,tag=zx.tjl_field] at @s run function sweetdream:equipment/bow/tiejili/field_clock
execute as @e[tag=zx.tjl_inside] at @s run function sweetdream:equipment/bow/tiejili/slow_enter
execute as @e[type=marker,tag=zx.tjl_lease] at @s run function sweetdream:equipment/bow/tiejili/lease with entity @s data.fx
