execute unless score @s zx.tjl_end matches 0.. run function sweetdream:equipment/bow/tiejili/legacy_field
execute if score @s zx.tjl_end <= #now manacore.meta run return run function sweetdream:equipment/bow/tiejili/field_end
execute if score @s zx.tjl_next <= #now manacore.meta run function sweetdream:equipment/bow/tiejili/field_tick
tag @e[type=!#sweetdream:no_damage,distance=..2.5] add zx.tjl_inside
