execute unless score @s zx.ld_t matches 1.. run scoreboard players set @s zx.ld_s 0
# No effects and no reads of player NBT. Safe before spending/gaining and each tick.
execute if score @s zx.ld_s matches 4.. run scoreboard players set @s zx.ld_s 3
execute if score @s zx.ld_t <= #now manacore.meta run scoreboard players set @s zx.ld_s 0
execute unless score @s zx.ld_s matches 1.. run scoreboard players set @s zx.ld_t 0
