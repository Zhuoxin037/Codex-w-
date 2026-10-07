# ============================================================
# sweetdream:equipment/axe/thunderclap/field_tick —— 术阵每秒推进(执行者 = 术阵 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[distance=0..,tag=zx.tc_field] at @s run function ...
# 【本函数在"每维度各跑一次"的链上】不要出现裸 @e(本文件里一条都没有)。
# 【每秒做什么】① 描一遍半径 6「领域」的边界(domain_fx) ② 计时 -1, 归零收场(field_end)
# ============================================================

# ① 领域表现(半径 6 的虚线环 + 淡电雾) —— 玩家据此判断"在不在领域里"
function sweetdream:equipment/axe/thunderclap/domain_fx

# ② 计时 -1, 归零收掉
scoreboard players remove @s zx.tc_ft 1
execute if score @s zx.tc_ft matches 1.. run return 0
function sweetdream:equipment/axe/thunderclap/field_end
