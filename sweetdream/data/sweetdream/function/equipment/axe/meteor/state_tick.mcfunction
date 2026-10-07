# ============================================================
# sweetdream:equipment/axe/meteor/state_tick —— 熔星形态每秒心跳
# ------------------------------------------------------------
# 【执行者】处于熔星形态的玩家
# ============================================================

scoreboard players remove @s zx.mt_on 1
execute if score @s zx.mt_on matches ..0 run function sweetdream:equipment/axe/meteor/end
