scoreboard players set #tj_old zx.meta 5
execute if score @s zx.tjl_ft matches 1..5 run scoreboard players operation #tj_old zx.meta = @s zx.tjl_ft
scoreboard players operation #tj_old zx.meta *= #20 zx.meta
scoreboard players operation @s zx.tjl_end = #now manacore.meta
scoreboard players operation @s zx.tjl_end += #tj_old zx.meta
scoreboard players operation @s zx.tjl_next = #now manacore.meta
