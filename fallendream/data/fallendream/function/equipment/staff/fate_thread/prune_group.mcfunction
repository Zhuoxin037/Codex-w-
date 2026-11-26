$data modify storage zx:ft frames[-1].f.queue set from storage zx:ft frames[-1].f.record.$(group)
data modify storage zx:ft frames[-1].f.keep set value []
function fallendream:equipment/staff/fate_thread/prune_loop
$data modify storage zx:ft frames[-1].f.record.$(group) set from storage zx:ft frames[-1].f.keep
