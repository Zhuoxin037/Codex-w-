# ============================================================
# sweetdream:equipment/sword/myriad/ju_tick —— 「居合」的每秒倒计时
# ------------------------------------------------------------
# 【执行者】zx.mq_ju >= 1 的玩家(由 ol_second 每秒挑出来)
# ============================================================

scoreboard players remove @s zx.mq_ju 1
execute if score @s zx.mq_ju matches ..0 run function sweetdream:equipment/sword/myriad/ju_end
