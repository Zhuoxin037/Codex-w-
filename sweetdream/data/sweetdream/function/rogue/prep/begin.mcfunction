function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
function sweetdream:rogue/prep/save_off with storage zx:work rg
execute unless score #rd_off_ok zx.meta matches 1 run return fail
tag @s remove zx.rg_wait
tag @s add zx.rg_prep
scoreboard players set @s zx.rg_prept 0
scoreboard players set @s zx.rg_room 10
scoreboard players set @s zx.rg_seen -1
scoreboard players set @s zx.rg_rev -1
execute in sweetdream:rogue_preview run tp @s 48.5 320 48.5 0 80
execute at @s run function sweetdream:rogue/map/repair
execute unless items entity @s hotbar.8 minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run return fail
item replace entity @s weapon.offhand from entity @s hotbar.8
