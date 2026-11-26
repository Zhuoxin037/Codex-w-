data modify storage zx:work fate_event set from storage zx:work hit_success_stack[-1].s2_source
data modify storage zx:work fate_event.actual set from storage zx:work hit_success_stack[-1].actual
data modify storage zx:work fate_event.vx_uuid set from storage zx:work hit_success_stack[-1].vx_uuid
function fallendream:equipment/staff/fate_thread/on_damage with storage zx:work fate_event
