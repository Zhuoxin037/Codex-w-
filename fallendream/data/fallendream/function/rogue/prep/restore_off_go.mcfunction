$execute if items entity @s weapon.offhand * unless items entity @s weapon.offhand *[minecraft:custom_data~{rg_map:1b}] run function fallendream:rogue/map/capture_slot {uuid:"$(uuid)",slot:"weapon.offhand"}
execute if items entity @s weapon.offhand * unless items entity @s weapon.offhand *[minecraft:custom_data~{rg_map:1b}] run return fail
execute if items entity @s weapon.offhand *[minecraft:custom_data~{rg_map:1b}] run item replace entity @s weapon.offhand with minecraft:air
$execute unless data storage zx:rogue p."$(uuid)".prep_off.id run return 1
kill @e[tag=zx.rg_tmp,distance=0..]
summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.rg_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b}
$data modify entity @e[tag=zx.rg_tmp,distance=0..,limit=1] equipment.mainhand set from storage zx:rogue p."$(uuid)".prep_off
scoreboard players set #rd_restore_ok zx.meta 0
execute if items entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand * unless items entity @s weapon.offhand * store success score #rd_restore_ok zx.meta run item replace entity @s weapon.offhand from entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand
$execute if score #rd_restore_ok zx.meta matches 1 run data remove storage zx:rogue p."$(uuid)".prep_off
kill @e[tag=zx.rg_tmp,distance=0..]
return run scoreboard players get #rd_restore_ok zx.meta
