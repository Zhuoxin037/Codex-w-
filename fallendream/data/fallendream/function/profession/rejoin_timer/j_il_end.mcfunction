scoreboard players operation @s zx.j_il_t = @s zx.j_il_end
scoreboard players operation @s zx.j_il_t -= #now manacore.meta
execute if score @s zx.j_il_t matches ..-1 run scoreboard players set @s zx.j_il_t 0
