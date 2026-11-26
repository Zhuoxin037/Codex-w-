scoreboard players operation @s zx.j_empath = @s zx.j_em_end
scoreboard players operation @s zx.j_empath -= #now manacore.meta
execute if score @s zx.j_empath matches ..-1 run scoreboard players set @s zx.j_empath 0
