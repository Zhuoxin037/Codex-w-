# ============================================================
# sweetdream:equipment/staff/polarized_light/half —— 超限光束的半秒心跳(每刻驱动)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a[scores={zx.pl_t=1..,zx.pl_ol=1}] at @s run ...
#   (执行者 = 施法玩家)
# 【为什么】超限·偏振光是"每 **0.5 秒**对 12 格内最近 3 个生物结算一次" ——
#   每秒入口(second)的节奏是 1 秒一格, 跟不上; 所以超限版挪到 core/tick,
#   用 zx.pl_ct 做闸: **10 刻(0.5 秒)结算一次**, 20 刻(1 秒)再结算一次并**扣 1 秒**。
# 【★ 干活频率 ≠ 持续时间(坑 120) ★】tick 里**不扣** zx.pl_t —— 闸是 0.5 秒,
#   在 tick 里扣 1 就等于把"秒"当"半秒", pl_t=5 只撑 2.5 秒(lore 写的是 5 秒)。
#   所以这里必须自己按真实时间扣: 每 20 刻 = 1 秒 -> 扣 1; 一秒里结算两次(10/20 刻)。
# 【基础版为什么不动】基础版仍走 second 每秒一次(second 里筛 zx.pl_ol=0),
#   两边互不见面 —— 不会双倍伤害。
# 【zx.pl_ct】0.5 秒闸的计数器(玩家身上), 注册在 core/load。
# ============================================================

scoreboard players add @s zx.pl_ct 1

# 第 10 刻(0.5 秒): 结算一次
execute if score @s zx.pl_ct matches 10 run function sweetdream:equipment/staff/polarized_light/tick

# 第 20 刻(1.0 秒): 再结算一次 + 扣掉 1 秒 + 计数器归零
#   ★ 用精确 matches(不带 ".." ): 归零前 ct 会一路涨到 20, 写成 "10.." 会每刻都结算。
execute if score @s zx.pl_ct matches 20 run function sweetdream:equipment/staff/polarized_light/tick
execute if score @s zx.pl_ct matches 20 run scoreboard players remove @s zx.pl_t 1
execute if score @s zx.pl_ct matches 20 run scoreboard players set @s zx.pl_ct 0
