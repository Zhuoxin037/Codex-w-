# ============================================================
# sweetdream:equipment/bow/cloudtrail/field_tick —— 「云迹」领域每秒推进
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[distance=0..,tag=zx.ct_field] at @s run ...
# 【执行者】领域 marker
# 【本函数在"每维度各跑一次"的链上】不要出现裸 @e(本文件里一条都没有)。
# 【每秒做什么】① 画一圈云气(玩家据此判断"在不在领域里") ② 计时 -1, 归零 kill 自己
# ============================================================

particle minecraft:cloud ~ ~0.1 ~ 3.0 0.1 3.0 0.01 25 normal
particle minecraft:end_rod ~ ~0.1 ~ 2.6 0.1 2.6 0.01 12 normal

scoreboard players remove @s zx.ct_ft 1
execute if score @s zx.ct_ft matches 1.. run return 0
kill @s
