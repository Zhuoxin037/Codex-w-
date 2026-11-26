function fallendream:batch21/shape/prepare
execute as @e[type=!#fallendream:no_damage,distance=..9] run function fallendream:batch21/shape/line
tag @e[tag=zx.s2_scene_landed,distance=..10] remove zx.s2_scene_landed
data modify storage zx:work a set value {target:"@e[tag=zx.s2_hit,distance=..9]",type:"fallendream:skill",uncapped:1b,s2_scene:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
data modify storage zx:work a.num set from storage zx:work s2_scene_origin.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work s2_scene_origin.s2_b_damage
data modify storage zx:work a.u0 set from storage zx:work s2_scene_origin.u0
data modify storage zx:work a.u1 set from storage zx:work s2_scene_origin.u1
data modify storage zx:work a.u2 set from storage zx:work s2_scene_origin.u2
data modify storage zx:work a.u3 set from storage zx:work s2_scene_origin.u3
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
execute as @e[tag=zx.s2_scene_landed,scores={zx.j_ess=1..},distance=..9] run function fallendream:equipment/sword/mirrored_scene/essence
tag @e[tag=zx.s2_scene_landed,distance=..10] remove zx.s2_scene_landed
tag @e[tag=zx.s2_hit,distance=..10] remove zx.s2_hit
execute rotated ~ 0 positioned ^ ^1 ^4 run particle minecraft:sweep_attack ~ ~ ~ 0 0 3 0 6 force
