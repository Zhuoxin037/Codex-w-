scoreboard players set #heal_pt zx.meta 1024
function sweetdream:lib/heal
attribute @s minecraft:max_absorption modifier remove sweetdream:prophecy_absorption
attribute @s minecraft:max_absorption modifier add sweetdream:prophecy_absorption -3 add_value
effect give @s minecraft:absorption 15 6 true
scoreboard players set @s zx.j_reborn 300
tellraw @s {"text":"抽中了新生的「预言」。","color":"light_purple"}

scoreboard players operation @s zx.j_abs_end = #now manacore.meta
scoreboard players add @s zx.j_abs_end 300
