execute unless data storage zx:ft frames[-1].f.queue[0] run return 0
data modify storage zx:ft frames[-1].f.node set from storage zx:ft frames[-1].f.queue[0].uuid
function fallendream:equipment/staff/fate_thread/prune_one with storage zx:ft frames[-1].f
data remove storage zx:ft frames[-1].f.queue[0]
function fallendream:equipment/staff/fate_thread/prune_loop
