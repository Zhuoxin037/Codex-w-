scoreboard players remove @s zx.j_ero_t 1
function sweetdream:profession/twin/forget
execute if score @s zx.j_ero_t matches ..0 run attribute @s minecraft:follow_range modifier remove sweetdream:erosion_amnesia
execute if score @s zx.j_ero_t matches ..0 run tag @s remove zx.j_eroded
