execute unless data storage zx:work hit_success_stack[-1].has_event run return 0
data modify storage zx:work ub set from storage zx:combat events[-1].event
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:internal/attack/close
