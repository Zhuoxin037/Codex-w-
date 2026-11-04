$execute if data storage zx:rogue floor.cells[{cell:$(cell),revealed:1b}] run return 0
$execute unless data storage zx:rogue floor.cells[{cell:$(cell),present:1b}] run return 0
$data modify storage zx:rogue floor.cells[$(cell)].revealed set value 1b
$function sweetdream:rogue/map/draw_icon with storage zx:rogue floor.cells[$(cell)]
