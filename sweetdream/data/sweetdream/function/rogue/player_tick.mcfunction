execute unless data storage zx:rogue {built:1b} run return run function sweetdream:rogue/prototype/exit
execute unless dimension sweetdream:rogue_preview run return run function sweetdream:rogue/map/release
execute if entity @s[y=-64,dy=135] run tp @s 0.5 81 48.5
scoreboard players add @s zx.rg_room 0
function sweetdream:rogue/map/locate
execute unless items entity @s hotbar.8 minecraft:filled_map[minecraft:custom_data~{rg_map:1b,rg_ver:2},minecraft:map_id=1900102900] run function sweetdream:rogue/map/repair
execute unless score @s zx.rg_room = @s zx.rg_seen run function sweetdream:rogue/map/refresh
execute unless score @s zx.rg_rev = #rd_rev zx.meta run function sweetdream:rogue/map/refresh
