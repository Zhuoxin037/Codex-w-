execute unless score @s zx.ld_t1 matches 0.. run function sweetdream:equipment/armor/late_dusk/migrate
execute if score @s zx.ld_t1 <= #now manacore.meta run scoreboard players set @s zx.ld_t1 0
execute if score @s zx.ld_t2 <= #now manacore.meta run scoreboard players set @s zx.ld_t2 0
execute if score @s zx.ld_t3 <= #now manacore.meta run scoreboard players set @s zx.ld_t3 0
execute if score @s zx.ld_t1 matches 0 run scoreboard players operation @s zx.ld_t1 >< @s zx.ld_t2
execute if score @s zx.ld_t2 matches 0 run scoreboard players operation @s zx.ld_t2 >< @s zx.ld_t3
execute if score @s zx.ld_t1 matches 0 run scoreboard players operation @s zx.ld_t1 >< @s zx.ld_t2
scoreboard players set @s zx.ld_s 0
execute if score @s zx.ld_t1 matches 1.. run scoreboard players add @s zx.ld_s 1
execute if score @s zx.ld_t2 matches 1.. run scoreboard players add @s zx.ld_s 1
execute if score @s zx.ld_t3 matches 1.. run scoreboard players add @s zx.ld_s 1
scoreboard players operation @s zx.ld_t = @s zx.ld_t1
