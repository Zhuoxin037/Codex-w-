$data modify storage zx:rogue floor.cells[$(cell)].visited set value 1b
$execute in fallendream:rogue_preview positioned $(x) 319 $(z) run function fallendream:rogue/canvas/visited
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] in fallendream:rogue_preview positioned $(x) 319 $(z) run function fallendream:rogue/canvas/boss_visited
function fallendream:rogue/map/reveal_neighbors
$function fallendream:rogue/map/draw_icon with storage zx:rogue floor.cells[$(cell)]
function fallendream:rogue/map/flags
scoreboard players add #rd_rev zx.meta 1
