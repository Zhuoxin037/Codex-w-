# 第一次只激活基础套装；窗口内再次满足条件才强化针眠分支。
scoreboard players set @s zx.ns_n 0
execute if score @s zx.ns_set_end > #now manacore.meta run scoreboard players operation @s zx.ns_boost_end = #now manacore.meta
execute if score @s zx.ns_set_end > #now manacore.meta run scoreboard players add @s zx.ns_boost_end 600
scoreboard players operation @s zx.ns_set_end = #now manacore.meta
scoreboard players add @s zx.ns_set_end 600
scoreboard players operation @s zx.ns_win = #now manacore.meta
execute at @s run particle minecraft:crit ~ ~1.2 ~ 0.4 0.5 0.4 0.1 16 normal
