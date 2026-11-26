# The map locator only calls this after the player's hitbox has cleared the threshold.
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"combat"}] run return run function sweetdream_floor:room/lock
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"elite"}] run return run function sweetdream_floor:room/lock
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"boss"}] run function sweetdream_floor:room/lock
