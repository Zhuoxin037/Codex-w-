execute if score @s zx.ov_hp matches 1.. run attribute @s minecraft:max_health modifier remove fallendream:ov_hp
execute if score #ovf_want zx.meta matches 4 run attribute @s minecraft:max_health modifier add fallendream:ov_hp 4 add_value
execute if score #ovf_want zx.meta matches 8 run attribute @s minecraft:max_health modifier add fallendream:ov_hp 8 add_value
scoreboard players operation @s zx.ov_hp = #ovf_want zx.meta
