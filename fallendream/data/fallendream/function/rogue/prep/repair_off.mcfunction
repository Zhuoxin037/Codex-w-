execute unless items entity @s hotbar.8 minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run function fallendream:rogue/map/repair
execute unless items entity @s hotbar.8 minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {slot:"weapon.offhand"}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
execute if items entity @s weapon.offhand * unless items entity @s weapon.offhand *[minecraft:custom_data~{rg_map:1b}] run function fallendream:rogue/map/capture_slot with storage zx:work rg
execute if items entity @s weapon.offhand * unless items entity @s weapon.offhand *[minecraft:custom_data~{rg_map:1b}] run return fail
item replace entity @s weapon.offhand from entity @s hotbar.8
