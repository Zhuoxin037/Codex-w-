scoreboard players set @s zx.ld_t1 0
scoreboard players set @s zx.ld_t2 0
scoreboard players set @s zx.ld_t3 0
execute if score @s zx.ld_s matches 1.. if score @s zx.ld_t > #now manacore.meta run scoreboard players operation @s zx.ld_t1 = @s zx.ld_t
execute if score @s zx.ld_s matches 2.. if score @s zx.ld_t > #now manacore.meta run scoreboard players operation @s zx.ld_t2 = @s zx.ld_t
execute if score @s zx.ld_s matches 3.. if score @s zx.ld_t > #now manacore.meta run scoreboard players operation @s zx.ld_t3 = @s zx.ld_t
