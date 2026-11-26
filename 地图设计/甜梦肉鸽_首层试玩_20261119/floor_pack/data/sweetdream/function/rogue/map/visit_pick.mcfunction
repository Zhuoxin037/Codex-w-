# This standalone floor charges exploration before the map records a newly entered room.
$execute unless data storage zx:rogue floor.cells[{cell:$(cell),present:1b}] run return 0
execute if entity @s[tag=sd.floor_run] unless data storage sweetdream_floor:run {exploration:1b} run function sweetdream_floor:room/migrate_exploration
$execute if entity @s[tag=sd.floor_run] unless score #room_anchor sd.floor matches $(cell) run function sweetdream_floor:room/admit with storage zx:rogue floor.cells[$(cell)]
$execute if score @s zx.rg_room matches $(cell) unless data storage zx:rogue floor.cells[{cell:$(cell),visited:1b}] run function sweetdream:rogue/map/visit with storage zx:rogue floor.cells[$(cell)]
