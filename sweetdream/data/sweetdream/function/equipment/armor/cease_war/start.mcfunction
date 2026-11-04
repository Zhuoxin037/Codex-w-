execute unless score @s zx.job matches 2 run return 0
execute unless items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run return 0
scoreboard players add @s zx.s2_cw_cd 0
execute if score @s zx.s2_cw_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.s2_cw_cd = #now manacore.meta
scoreboard players add @s zx.s2_cw_cd 320
scoreboard players operation @s zx.s2_cw_end = #now manacore.meta
scoreboard players add @s zx.s2_cw_end 160
tag @s add zx.s2_cw
attribute @s minecraft:armor modifier remove sweetdream:cease_war
attribute @s minecraft:knockback_resistance modifier remove sweetdream:cease_war
attribute @s minecraft:armor modifier add sweetdream:cease_war 6 add_value
attribute @s minecraft:knockback_resistance modifier add sweetdream:cease_war 0.3 add_value
