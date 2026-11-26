$data modify storage zx:work jt_save_key set value "$(guard_key)"
$data remove storage zx:jobs p."$(uuid)".guard
$data modify storage zx:jobs p."$(uuid)".guard."$(guard_key)" set from entity @e[tag=zx.j_item_tmp,limit=1] equipment.mainhand
execute if data storage zx:work {jt_save_key:"main"} run scoreboard players set @s zx.j_guard_slot 1
execute if data storage zx:work {jt_save_key:"off"} run scoreboard players set @s zx.j_guard_slot 2

$data modify storage zx:jobs p."$(uuid)".guard."$(guard_key)".count set value 1
