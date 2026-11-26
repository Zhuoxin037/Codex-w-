# Finish native slot restoration first, then clear every item belonging to the ended session.
function sweetdream:profession/cleanup
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run function sweetdream_floor:run/clear_escrow with storage zx:data self
tag @s remove zx.rg_pending
clear @s
function sweetdream_floor:run/clear_chest
tag @s remove sd.floor_kit
tag @s add sd.floor_kit_clean
