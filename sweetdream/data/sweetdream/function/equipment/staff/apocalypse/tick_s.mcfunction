# ============================================================
# sweetdream:equipment/staff/apocalypse/tick_s —— 灾示状态的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【★ 必须写 at @s ★】灾示要"自身 8 格内", 全要相对玩家算(见 charge/second)。
# 【为什么单独一层】second.json 挂的是本文件; 真正的节奏在 tick_go
#   (执行者 = 玩家), 这层只负责"筛出灾示状态中的玩家"。
# ============================================================

execute as @a[scores={zx.ap_on=1..}] at @s run function sweetdream:equipment/staff/apocalypse/tick_go
