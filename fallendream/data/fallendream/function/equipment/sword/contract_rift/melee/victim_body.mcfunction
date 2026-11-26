$execute unless entity $(vx_uuid) run return 0
$execute store result storage zx:work crhit.t0 int 1 run data get entity $(vx_uuid) UUID[0]
$execute store result storage zx:work crhit.t1 int 1 run data get entity $(vx_uuid) UUID[1]
$execute store result storage zx:work crhit.t2 int 1 run data get entity $(vx_uuid) UUID[2]
$execute store result storage zx:work crhit.t3 int 1 run data get entity $(vx_uuid) UUID[3]
function fallendream:equipment/sword/contract_rift/melee_find with storage zx:work crhit
$tag $(vx_uuid) remove zx.victim
