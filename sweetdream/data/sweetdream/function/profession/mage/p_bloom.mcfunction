scoreboard players set @s zx.j_bloom 120
tellraw @s {"text":"抽中了蓬勃的「预言」。","color":"light_purple"}

scoreboard players operation @s zx.j_bloom_end = #now manacore.meta
scoreboard players add @s zx.j_bloom_end 120
