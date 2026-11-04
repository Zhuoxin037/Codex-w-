execute unless data storage zx:rogue {built:1b} run return run function sweetdream:rogue/prototype/exit
execute unless dimension sweetdream:rogue_preview run return run function sweetdream:rogue/prototype/exit
tp @s 48.5 320 48.5 0 80
execute unless items entity @s hotbar.8 minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run function sweetdream:rogue/map/repair
execute unless items entity @s weapon.offhand minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run function sweetdream:rogue/prep/repair_off
scoreboard players add @s zx.rg_prept 1
execute if score @s zx.rg_prept matches 40.. run function sweetdream:rogue/prototype/enter
