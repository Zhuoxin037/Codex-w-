$data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=..$(x)]",type:"fallendream:skill",uncapped:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),num:0.0}
data modify storage zx:work a.num set from storage zx:work fox8.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work fox8.s2_b_damage
function fallendream:lib/num/plain
data modify storage zx:work fox8.attack set from storage zx:work a
scoreboard players operation #fox8_left zx.meta = #fox8_x zx.meta
function fallendream:equipment/staff/eight_tail/repeat
