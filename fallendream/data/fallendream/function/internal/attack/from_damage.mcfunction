# Executor is the victim. Build an immutable direct-hit input before changing actor.
execute unless data storage zx:work hit_success_stack[-1].result{ok:1b} run return 0
scoreboard players set #atk_actual zx.meta 0
execute store result score #atk_actual zx.meta run data get storage zx:work hit_success_stack[-1].actual
execute if score #atk_actual zx.meta matches ..0 run return 0
data modify storage zx:combat input set value {kind:"extra",actual:0,vx_uuid:"",u0:0,u1:0,u2:0,u3:0,chain:0}
data modify storage zx:combat input.was set from storage zx:work hit_success_stack[-1].was
data modify storage zx:combat input.kind set from storage zx:work hit_success_stack[-1].s2_source.attack_kind
data modify storage zx:combat input.actual set from storage zx:work hit_success_stack[-1].actual
data modify storage zx:combat input.vx_uuid set from storage zx:work hit_success_stack[-1].vx_uuid
data modify storage zx:combat input.u0 set from storage zx:work hit_success_stack[-1].s2_source.u0
data modify storage zx:combat input.u1 set from storage zx:work hit_success_stack[-1].s2_source.u1
data modify storage zx:combat input.u2 set from storage zx:work hit_success_stack[-1].s2_source.u2
data modify storage zx:combat input.u3 set from storage zx:work hit_success_stack[-1].s2_source.u3
data modify storage zx:combat input.chain set from storage zx:work hit_success_stack[-1].s2_source.chain
execute if data storage zx:combat input{kind:"extra"} run function fallendream:equipment/armor/empty_pillow/remember_damage with storage zx:combat input
execute if data storage zx:combat input{kind:"dot"} run function fallendream:equipment/armor/empty_pillow/remember_damage with storage zx:combat input
execute if data storage zx:combat input{kind:"extra"} run return run function fallendream:internal/attack/chain_credit_event with storage zx:combat input
execute if data storage zx:combat input{kind:"dot"} run return run function fallendream:internal/attack/chain_credit_event with storage zx:combat input
data modify storage zx:work ub set from storage zx:combat input
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] at @s run function fallendream:internal/attack/pipe_event
