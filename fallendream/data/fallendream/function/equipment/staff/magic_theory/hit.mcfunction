data modify storage zx:work nh_snapshot set from entity @s
function fallendream:lib/entity_uuid/build
data modify storage zx:work s2_rail_key set from storage zx:work s2_rail
data modify storage zx:work s2_rail_key.target set from storage zx:work native_uuid.uuid
function fallendream:equipment/staff/magic_theory/count with storage zx:work s2_rail_key
$data modify storage zx:work a set value {target:"@s",type:"fallendream:skill",uncapped:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),num:0.0}
data modify storage zx:work a.num set from storage zx:work s2_rail_damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work s2_b_s2_rail_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
