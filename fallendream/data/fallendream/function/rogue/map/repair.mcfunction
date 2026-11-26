function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
execute if items entity @s hotbar.8 * unless items entity @s hotbar.8 *[minecraft:custom_data~{rg_map:1b}] run function fallendream:rogue/map/capture with storage zx:work rg
execute if items entity @s hotbar.8 * unless items entity @s hotbar.8 *[minecraft:custom_data~{rg_map:1b}] run return fail
clear @s *[minecraft:custom_data~{rg_map:1b}]
item replace entity @s hotbar.8 with minecraft:filled_map[minecraft:map_id=1900102900,minecraft:custom_data={rg_map:1b,rg_ver:2},minecraft:item_model="fallendream:rogue_map",minecraft:item_name={text:"楼层地图",color:"gold"},minecraft:max_stack_size=1]
function fallendream:rogue/map/refresh
