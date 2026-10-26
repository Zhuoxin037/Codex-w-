scoreboard players operation @s zx.j_cr_t = @s zx.j_cr_end
scoreboard players operation @s zx.j_cr_t -= #now manacore.meta
execute if score @s zx.j_cr_t matches ..-1 run scoreboard players set @s zx.j_cr_t 0
