# ============================================================
# sweetdream:equipment/axe/thunderclap/field_tick —— 术阵每秒推进(执行者 = 术阵 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[distance=0..,tag=zx.tc_field] at @s run function ...
# 【本函数在"每维度各跑一次"的链上】不要出现裸 @e(本文件里一条都没有)。
# 【每秒做什么】① 描一遍半径 6「领域」的边界(domain_fx) ② 计时 -1, 归零收场(field_end)
# ============================================================

# ① 领域表现(半径 6 的虚线环 + 淡电雾) —— 玩家据此判断"在不在领域里"
function sweetdream:equipment/axe/thunderclap/domain_fx

# ②-b 【R03 卸载补偿】区块卸载期间 zx.tc_ft 不会 -1, 但全局时钟与框架术阵照走 ⇒
#   重进后 marker 会比框架记录的多活一段。marker 出生时存了绝对到期 tick(zx.tc_end,
#   = gametime + 持续秒×20, 见 open ④-b) —— 这里先核对: 已经到点就直接把倒计时清零,
#   让下面原有的 "matches 1.. -> return / field_end" 走同一条收场路径(领域/落雷/清 tc_on 全一致)。
#   ★ 没存过 zx.tc_end 的旧 marker(本改动之前开的)两条条件都不成立 ⇒ 行为照旧。
execute store result score #tc_now zx.meta run time query gametime
execute if score @s zx.tc_end matches 1.. if score @s zx.tc_end <= #tc_now zx.meta run scoreboard players set @s zx.tc_ft 0

# ② 计时 -1, 归零收掉
scoreboard players remove @s zx.tc_ft 1
execute if score @s zx.tc_ft matches 1.. run return 0
function sweetdream:equipment/axe/thunderclap/field_end
