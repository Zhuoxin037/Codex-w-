scoreboard players operation #ld_new zx.meta = #now manacore.meta
scoreboard players add #ld_new zx.meta 160
execute if score @s zx.ld_s matches 0 run scoreboard players operation @s zx.ld_t1 = #ld_new zx.meta
execute if score @s zx.ld_s matches 1 run scoreboard players operation @s zx.ld_t2 = #ld_new zx.meta
execute if score @s zx.ld_s matches 2 run scoreboard players operation @s zx.ld_t3 = #ld_new zx.meta
scoreboard players add @s zx.ld_s 1
scoreboard players add #ld_added zx.meta 1
scoreboard players operation @s zx.ld_t = @s zx.ld_t1
