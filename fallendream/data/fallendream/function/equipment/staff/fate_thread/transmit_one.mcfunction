$execute if data storage zx:ft frames[-1].f{source:"$(uuid)"} run return 0
$execute if data storage zx:ft frames[-1].f.seen."$(uuid)" run return 0
$execute unless entity $(uuid) run return 0
$execute as $(uuid) if data entity @s {Health:0.0f} run return 0
$data modify storage zx:ft frames[-1].f.node set value "$(uuid)"
function fallendream:equipment/staff/fate_thread/transmit_bounds with storage zx:ft frames[-1].f
execute unless data storage zx:ft frames[-1].f{in_range:1b} run return 0
$data modify storage zx:ft frames[-1].f.seen."$(uuid)" set value 1b
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage zx:ft frames[-1].f.actual
scoreboard players set #mp_mul zx.meta 300
execute if data storage zx:ft frames[-1].f.record{mode:1} run scoreboard players set #mp_mul zx.meta 500
$execute if data storage zx:ft frames[-1].f.record{mode:1} if data storage zx:ft frames[-1].f.record.a[{uuid:"$(uuid)"}] if data storage zx:ft frames[-1].f.record.b[{uuid:"$(uuid)"}] run scoreboard players set #mp_mul zx.meta 800
function fallendream:lib/math/mul_permille
execute if score #mp_out zx.meta matches ..0 run return 0
$data modify storage zx:work a set value {target:"$(uuid)",type:"fallendream:true_damage",fixed:1b,uncapped:1b,attack_kind:"extra",num:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.num double 0.001 run scoreboard players get #mp_out zx.meta
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:lib/num/plain
function fallendream:internal/damage/with_from with storage zx:work a
