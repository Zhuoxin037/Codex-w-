$data modify storage zx:work rd_assign set from storage zx:rogue floor.unassigned[$(pick)]
$data remove storage zx:rogue floor.unassigned[$(pick)]
$data modify storage zx:work rd_assign.kind set value "$(kind)"
execute store result storage zx:work rd_assign.variant int 1 run random value 0..2 sweetdream:rogue
function sweetdream:rogue/gen/assign_apply with storage zx:work rd_assign
