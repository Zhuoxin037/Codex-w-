scoreboard players remove @s zx.j_ero_t 1
function fallendream:profession/twin/forget
execute if score @s zx.j_ero_t matches ..0 run attribute @s minecraft:follow_range modifier remove fallendream:erosion_amnesia
execute if score @s zx.j_ero_t matches ..0 run tag @s remove zx.j_eroded
