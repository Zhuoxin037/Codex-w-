scoreboard players set #jbrefresh zx.meta 1
scoreboard players operation #jbminimum zx.meta = @s zx.j_b_t1
execute if score @s zx.j_aw matches 1 if score @s zx.j_b_t2 < #jbminimum zx.meta run scoreboard players set #jbrefresh zx.meta 2
execute if score #jbrefresh zx.meta matches 2 run scoreboard players operation #jbminimum zx.meta = @s zx.j_b_t2
execute if score @s zx.j_aw matches 1 if score @s zx.j_b_t3 < #jbminimum zx.meta run scoreboard players set #jbrefresh zx.meta 3
execute if score #jbrefresh zx.meta matches 1 run scoreboard players operation @s zx.j_b_t1 = #now manacore.meta
execute if score #jbrefresh zx.meta matches 1 run scoreboard players add @s zx.j_b_t1 160
execute if score #jbrefresh zx.meta matches 2 run scoreboard players operation @s zx.j_b_t2 = #now manacore.meta
execute if score #jbrefresh zx.meta matches 2 run scoreboard players add @s zx.j_b_t2 160
execute if score #jbrefresh zx.meta matches 3 run scoreboard players operation @s zx.j_b_t3 = #now manacore.meta
execute if score #jbrefresh zx.meta matches 3 run scoreboard players add @s zx.j_b_t3 160
