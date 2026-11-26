# 执行者为追随者；每次附近玩家成功施法都更新上一施法时间。
scoreboard players add @s zx.j_duet_n 0
scoreboard players add @s zx.j_duet_cast 0
scoreboard players add @s zx.j_duet_last 0
scoreboard players operation #j_duet_window zx.meta = #now manacore.meta
scoreboard players operation #j_duet_window zx.meta -= @s zx.j_duet_cast
scoreboard players operation #j_duet_gap zx.meta = #now manacore.meta
scoreboard players operation #j_duet_gap zx.meta -= @s zx.j_duet_last
execute if score @s zx.j_duet_n matches ..2 if score #j_duet_window zx.meta matches 0..40 if score #j_duet_gap zx.meta matches 60.. run function fallendream:profession/singer/duet_go
scoreboard players operation @s zx.j_duet_cast = #now manacore.meta
