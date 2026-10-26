function sweetdream:profession/ensure
execute if score @s zx.job matches 0 run tellraw @s {"text":"「我」没有可强化的职业被动。","color":"gray"}
execute if score @s zx.job matches 0 run return 0
execute if score @s zx.job matches 3 run tellraw @s {"text":"歌者的醒梦强化效果尚待补充。","color":"gray"}
execute if score @s zx.job matches 3 run return 0
execute if score @s zx.j_aw matches 1 run tellraw @s {"text":"当前职业已经完成醒梦强化。","color":"gray"}
execute if score @s zx.j_aw matches 1 run return 0
scoreboard players set @s zx.j_aw 1
execute if score @s zx.job matches 1 run scoreboard players set @s zx.j_aw_m 1
execute if score @s zx.job matches 2 run scoreboard players set @s zx.j_aw_b 1
execute if score @s zx.job matches 4 run scoreboard players set @s zx.j_aw_t 1
tellraw @s {"text":"当前职业被动已强化。","color":"gold"}
