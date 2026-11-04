# Wait for the last visitor. Keep cleanup advancing even when a new visitor queues.
execute if entity @a[tag=zx.rg_active] run return 0
execute if entity @a[tag=zx.rg_prep] run return 0
execute if entity @a[tag=zx.rg_wait] run return 0
execute if score #rv_clean zx.meta matches 1.. run return 0
execute if data storage zx:rogue {built:1b} run return run function sweetdream:rogue/cleanup/request
execute if score #rd_phase zx.meta matches 1.. run return run function sweetdream:rogue/cleanup/request
execute if score #rd_forced zx.meta matches 1 run function sweetdream:rogue/cleanup/request
