scoreboard players set @s zx.j_ero 0
scoreboard players set @s zx.j_ero_t 100
scoreboard players operation @s zx.j_ero_pct = #jero_pct zx.meta
attribute @s minecraft:follow_range modifier remove sweetdream:erosion_amnesia
attribute @s minecraft:follow_range modifier add sweetdream:erosion_amnesia -1 add_multiplied_total
tag @s add zx.j_eroded
function sweetdream:profession/twin/forget
