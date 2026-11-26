# Shared integer identity; no player NBT serialization and no UUID-prefix collisions.
execute if score @s zx.sid matches 1.. run return 0
scoreboard players add #entity_id zx.meta 1
scoreboard players operation @s zx.sid = #entity_id zx.meta
