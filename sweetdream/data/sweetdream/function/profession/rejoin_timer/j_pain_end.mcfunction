scoreboard players operation @s zx.j_pain = @s zx.j_pain_end
scoreboard players operation @s zx.j_pain -= #now manacore.meta
execute if score @s zx.j_pain matches ..-1 run scoreboard players set @s zx.j_pain 0
