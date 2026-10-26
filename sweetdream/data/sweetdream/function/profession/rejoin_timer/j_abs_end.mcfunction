scoreboard players operation @s zx.j_reborn = @s zx.j_abs_end
scoreboard players operation @s zx.j_reborn -= #now manacore.meta
execute if score @s zx.j_reborn matches ..-1 run scoreboard players set @s zx.j_reborn 0
