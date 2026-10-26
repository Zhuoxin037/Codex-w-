# Canonical UUID arguments resolve still-loaded dead bodies; @e would skip them.
execute unless data storage zx:native registry[0] run return 0
data modify storage zx:work native_dead_queue set from storage zx:native registry
function sweetdream:internal/native/dead_loop
