$execute positioned $(x) 80 $(z) run function fallendream:rogue/rooms/$(kind)_$(variant)
$execute positioned $(x) 319 $(z) run function fallendream:rogue/canvas/room
$execute positioned $(x) 319 $(z) if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] run function fallendream:rogue/canvas/boss
