# ============================================================
# sweetdream:equipment/bow/arc/ol_sweep —— 超限·电弧: 放电窗口计时(安全网)
# ------------------------------------------------------------
# 【谁调用它】lib/second(三维度各一行)
# 【它做什么】把所有 zx.arc_dt ≥ 1 的生物的窗口计时 -1(到 0 自然停)
# 【★ 为什么还要这一条】窗口计时本来由 ol_end_go 在锚收尾时归零; 但锚可能因为
#   端点提前消失、区块卸载等原因先死 —— 这一条保证"窗口"最多只持续 3 秒, 不会
#   永久卡住"这一对"拒绝再起放电(ol_begin ⓪)。
# 【★ 为什么不用 @a】两端是**非玩家生物**(hook_victim 明确排除玩家), @a 抓不到;
#   非玩家实体分数会随实体存续, 所以必须按维度扫 @e。
# ============================================================

execute in minecraft:overworld as @e[scores={zx.arc_dt=1..},distance=0..] run scoreboard players remove @s zx.arc_dt 1
execute in minecraft:the_nether as @e[scores={zx.arc_dt=1..},distance=0..] run scoreboard players remove @s zx.arc_dt 1
execute in minecraft:the_end as @e[scores={zx.arc_dt=1..},distance=0..] run scoreboard players remove @s zx.arc_dt 1
