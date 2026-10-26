$execute unless entity @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}},limit=1] run function sweetdream:profession/twin/guard_carrier_new
$execute if score @s zx.j_guard_slot matches 1 if items entity @s weapon.mainhand *[custom_data~{j_protect:1b}] run item replace entity @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}},limit=1] weapon.mainhand from entity @s weapon.mainhand
$execute if score @s zx.j_guard_slot matches 2 if items entity @s weapon.offhand *[custom_data~{j_protect:1b}] run item replace entity @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}},limit=1] weapon.mainhand from entity @s weapon.offhand
$execute if score @s zx.j_guard_slot matches 1 run data modify storage zx:jobs p."$(uuid)".guard.main set from entity @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}},limit=1] equipment.mainhand
$execute if score @s zx.j_guard_slot matches 2 run data modify storage zx:jobs p."$(uuid)".guard.off set from entity @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}},limit=1] equipment.mainhand
$execute if score @s zx.j_guard_slot matches 1 run data modify storage zx:jobs p."$(uuid)".guard.main.count set value 1
$execute if score @s zx.j_guard_slot matches 2 run data modify storage zx:jobs p."$(uuid)".guard.off.count set value 1
