tag @s remove zx.rg_active
tag @s remove zx.rg_wait
tag @s remove zx.rg_prep
clear @s *[minecraft:custom_data~{rg_map:1b}]
scoreboard players reset @s zx.rg_room
scoreboard players reset @s zx.rg_seen
scoreboard players reset @s zx.rg_rev
scoreboard players reset @s zx.rg_prept
execute if entity @s[tag=zx.rg_pending] run function sweetdream:rogue/map/return_pending
function sweetdream:rogue/prototype/maybe_unload
