function fallendream:internal/attack/open
data modify storage zx:work hit_success_stack[-1].has_event set value 1b
data modify storage zx:work hit_success_stack[-1].s2_source.chain set from storage zx:combat events[-1].event.chain
execute unless data storage zx:combat events[-1].event{kind:"skill"} if data storage zx:combat events[-1].event.was{borrow_fire:1b} if score @s zx.atk_ok matches 1 run function fallendream:equipment/armor/borrow_fire/basic_attack with storage zx:combat events[-1].event
function fallendream:internal/attack/dispatch
