$data modify storage zx:rogue floor.cells[$(cell)].visited set value 1b
$execute in sweetdream:rogue_preview positioned $(x) 319 $(z) run function sweetdream:rogue/canvas/visited
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] in sweetdream:rogue_preview positioned $(x) 319 $(z) run function sweetdream:rogue/canvas/boss_visited
function sweetdream:rogue/map/reveal_neighbors
$function sweetdream:rogue/map/draw_icon with storage zx:rogue floor.cells[$(cell)]
function sweetdream:rogue/map/flags
scoreboard players add #rd_rev zx.meta 1
