# ============================================================
# sweetdream:equipment/staff/polarized_light/half —— 超限光束的半秒心跳(每刻驱动)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a[scores={zx.pl_t=1..,zx.pl_ol=1}] at @s run ...
#   (执行者 = 施法玩家)
# 【为什么】超限·偏振光是"每 **0.5 秒**对 12 格内最近 3 个生物结算一次" ——
#   每秒入口(second)的节奏是 1 秒一格, 跟不上; 所以超限版挪到 core/tick,
#   用 zx.pl_ct 做 10 刻闸(10 刻 = 0.5 秒), 到闸就跑一次 tick(锁目标/伤害/缓慢/倒计时)。
# 【基础版为什么不动】基础版仍走 second 每秒一次(second 里筛 zx.pl_ol=0),
#   两边互不见面 —— 不会双倍伤害。
# 【zx.pl_ct】0.5 秒闸的计数器(玩家身上), 注册在 core/load。
# ============================================================

scoreboard players add @s zx.pl_ct 1
execute if score @s zx.pl_ct matches 10.. run function sweetdream:equipment/staff/polarized_light/tick
execute if score @s zx.pl_ct matches 10.. run scoreboard players set @s zx.pl_ct 0
