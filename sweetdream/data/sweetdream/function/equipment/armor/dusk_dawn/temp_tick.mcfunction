# ============================================================
# sweetdream:equipment/armor/dusk_dawn/temp_tick —— 临时上限的每秒倒计时
# ------------------------------------------------------------
# 【执行者】zx.dd_temp >= 1 的玩家
# 【到点做什么】把"已经加进去的"减回去(就是把 zx.dd_app 清零的过程), 见 temp_off。
# ============================================================

scoreboard players remove @s zx.dd_temp 1
execute if score @s zx.dd_temp matches ..0 run function sweetdream:equipment/armor/dusk_dawn/temp_off
