execute unless data storage zx:work native_gc_queue[0] run return 0
function sweetdream:internal/native/gc_one with storage zx:work native_gc_queue[0]
data remove storage zx:work native_gc_queue[0]
execute if data storage zx:work native_gc_queue[0] run function sweetdream:internal/native/gc_loop
