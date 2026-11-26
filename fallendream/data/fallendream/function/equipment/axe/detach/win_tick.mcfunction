# ============================================================
# fallendream:equipment/axe/detach/win_tick —— 8 秒窗口每秒 -1（记在被命中的生物身上）
# ------------------------------------------------------------
# 【谁调用它】lib/second 的三维度循环（选择器按 scores={zx.dt_wend=1..} 筛，平时空扫）
# 【执行者】被打的那只生物
# 【★ 为什么记在生物身上 ★】"该生物"是唯一的判据；记在玩家身上就得再存一份 UUID
#   才能回收，而生物自己带着倒计时会自然到期，不需要任何反查。
# ============================================================

scoreboard players remove @s zx.dt_wend 1
execute if score @s zx.dt_wend matches ..0 run scoreboard players reset @s zx.dt_wend
