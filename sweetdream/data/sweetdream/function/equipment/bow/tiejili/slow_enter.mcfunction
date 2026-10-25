execute unless score @s zx.tjl_id matches 1.. run scoreboard players add #tjl_serial zx.meta 1
execute unless score @s zx.tjl_id matches 1.. run scoreboard players operation @s zx.tjl_id = #tjl_serial zx.meta
execute store result storage zx:work tj_lease.id int 1 run scoreboard players get @s zx.tjl_id
function sweetdream:equipment/bow/tiejili/slow_enter_go with storage zx:work tj_lease
