execute unless data storage zx:work native_dead_queue[0] run return 0
data modify storage zx:work native_dead_request set from storage zx:work native_stack[-1]
data modify storage zx:work native_dead_request.uuid set from storage zx:work native_dead_queue[0].uuid
function sweetdream:internal/native/dead_one with storage zx:work native_dead_request
data remove storage zx:work native_dead_queue[0]
execute if data storage zx:work native_dead_queue[0] run function sweetdream:internal/native/dead_loop
