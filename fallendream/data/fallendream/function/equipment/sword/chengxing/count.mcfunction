# ============================================================
# fallendream:equipment/sword/chengxing/count —— 超限「每攻击 4 次」的计数
# ------------------------------------------------------------
# 【执行者】玩家（由 hit.mcfunction 在超限分支里调用，一击一次）
# 【账本】zx.cx_cnt = 已累计次数(0..4) / zx.cx_rdy = 下一次攻击可被增幅(1)
# 【时序】第 4 次命中 → cnt 归零、rdy 置 1；第 5 次命中时由 amp_hit 兑现并清零 rdy。
#   ★ 归零与置位写在同一行之后，读起来是"打满 4 下就发一张券"。
# ============================================================

scoreboard players add @s zx.cx_cnt 1
execute if score @s zx.cx_cnt matches 4.. run scoreboard players set @s zx.cx_cnt 0
execute if score @s zx.cx_cnt matches 0 run scoreboard players set @s zx.cx_rdy 1
