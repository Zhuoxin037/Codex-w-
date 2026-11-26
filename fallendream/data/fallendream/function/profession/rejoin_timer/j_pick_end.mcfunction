scoreboard players operation @s zx.j_pick_t = @s zx.j_pick_end
scoreboard players operation @s zx.j_pick_t -= #now manacore.meta
execute if score @s zx.j_pick_t matches ..-1 run scoreboard players set @s zx.j_pick_t 0
