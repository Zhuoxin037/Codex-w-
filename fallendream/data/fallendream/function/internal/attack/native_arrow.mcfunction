advancement revoke @s only fallendream:internal/attack_arrow
execute if data storage zx:work hit_success_stack[-1] run return 0
execute if data storage zx:combat events[-1].event run return 0
data modify storage zx:combat ranged_search set value 1b
function fallendream:lib/victim
data remove storage zx:combat ranged_search
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:combat input set value {kind:"arrow",actual:0,vx_uuid:"",u0:0,u1:0,u2:0,u3:0,chain:0}
data modify storage zx:combat input.vx_uuid set from storage zx:victim context.vx_uuid
execute store result storage zx:combat input.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:combat input.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:combat input.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:combat input.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:internal/attack/native_amount with storage zx:combat input
execute unless data storage zx:combat input{valid:1b} run return 0
function fallendream:internal/attack/open
function fallendream:internal/native/start {melee:0}
execute if data storage zx:combat events[-1].event.was{borrow_fire:1b} if score @s zx.atk_ok matches 1 run function fallendream:equipment/armor/borrow_fire/basic_attack with storage zx:combat events[-1].event
function fallendream:equipment/staff/fate_thread/on_damage with storage zx:combat events[-1].event
function fallendream:internal/attack/dispatch
function fallendream:internal/attack/close
