$data modify storage zx:work rd_corridor set from storage zx:rogue floor.cells[$(a)]
$data modify storage zx:work rd_corridor.r1 set from storage zx:rogue floor.cells[$(a)].radius
$data modify storage zx:work rd_corridor.r2 set from storage zx:rogue floor.cells[$(b)].radius
$data modify storage zx:work rd_corridor.axis set value "$(axis)"
function fallendream:rogue/gen/corridor with storage zx:work rd_corridor
