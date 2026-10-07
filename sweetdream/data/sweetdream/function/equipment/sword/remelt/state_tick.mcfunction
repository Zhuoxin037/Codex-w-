# ============================================================
# sweetdream:equipment/sword/remelt/state_tick —— 熔解状态每秒心跳
# ------------------------------------------------------------
# 【执行者】处于熔解状态的玩家
# ============================================================

scoreboard players remove @s zx.rm_on 1
execute if score @s zx.rm_on matches ..0 run function sweetdream:equipment/sword/remelt/end
