$execute positioned $(x) 80 $(z) run function sweetdream:rogue/rooms/$(kind)_$(variant)
$execute positioned $(x) 319 $(z) run function sweetdream:rogue/canvas/room
$execute positioned $(x) 319 $(z) if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] run function sweetdream:rogue/canvas/boss
