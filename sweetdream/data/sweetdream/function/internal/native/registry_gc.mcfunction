execute unless data storage zx:native registry[0] run return 0
scoreboard players add #native_gen zx.meta 1
data modify storage zx:work native_gc_queue set from storage zx:native registry
data modify storage zx:work native_gc_next set value []
function sweetdream:internal/native/gc_loop
data modify storage zx:native registry set from storage zx:work native_gc_next
