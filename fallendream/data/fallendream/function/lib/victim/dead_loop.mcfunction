data modify storage zx:work vx_request set from storage zx:work v
data modify storage zx:work vx_request.uuid set from storage zx:work vx_queue[0].uuid
function fallendream:lib/victim/dead_one with storage zx:work vx_request
data remove storage zx:work vx_queue[0]
execute if data storage zx:work vx_queue[0] run function fallendream:lib/victim/dead_loop
