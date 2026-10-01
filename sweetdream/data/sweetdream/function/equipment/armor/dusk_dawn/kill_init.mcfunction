# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_init —— 同一次击杀只清一次账
# ------------------------------------------------------------
# 【为什么需要它】"击杀 200"和"杀的怪带标签再 +100"是**两条进度**,
#   而两条进度奖励函数的**执行顺序不可控**(而且大概率是"带标签那条"先跑)。
#   所以让两个函数都先调这里: 用"当前时刻"判断是不是同一次击杀 ——
#   第一次调进来才把两个账本清零, 第二次直接 return。
# 【为什么用 #now 当代替"击杀编号"】同一 tick 内两条进度奖励都会跑完,
#   所以"时刻相同"就等于"同一次击杀", 不用额外维护计数器。
# ============================================================

scoreboard players add @s zx.dd_know 0
execute if score @s zx.dd_know = #now manacore.meta run return 0
scoreboard players set @s zx.dd_t1 0
scoreboard players set @s zx.dd_t2 0
scoreboard players operation @s zx.dd_know = #now manacore.meta
