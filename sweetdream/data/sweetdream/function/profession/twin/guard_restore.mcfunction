summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.j_item_tmp"],Marker:1b,Invisible:1b,NoGravity:1b}
execute if score @s zx.j_guard_slot matches 1 run function sweetdream:profession/twin/restore_guard_hand {hand:"weapon.mainhand",key:"main"}
execute if score @s zx.j_guard_slot matches 2 run function sweetdream:profession/twin/restore_guard_hand {hand:"weapon.offhand",key:"off"}
kill @e[tag=zx.j_item_tmp]
