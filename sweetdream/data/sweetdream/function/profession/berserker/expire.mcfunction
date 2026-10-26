scoreboard players set #jbsum zx.meta 0
execute unless score @s zx.j_b_t1 > #now manacore.meta run scoreboard players set @s zx.j_b_v1 0
scoreboard players add @s zx.j_b_v1 0
scoreboard players operation #jbsum zx.meta += @s zx.j_b_v1
execute unless score @s zx.j_b_t2 > #now manacore.meta run scoreboard players set @s zx.j_b_v2 0
scoreboard players add @s zx.j_b_v2 0
scoreboard players operation #jbsum zx.meta += @s zx.j_b_v2
execute unless score @s zx.j_b_t3 > #now manacore.meta run scoreboard players set @s zx.j_b_v3 0
scoreboard players add @s zx.j_b_v3 0
scoreboard players operation #jbsum zx.meta += @s zx.j_b_v3
