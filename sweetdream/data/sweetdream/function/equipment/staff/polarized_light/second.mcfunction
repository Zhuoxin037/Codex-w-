# ============================================================
# sweetdream:equipment/staff/polarized_light/second —— 偏振光的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【★ 必须写 at @s ★】光线锁 10 格内最近, 全要相对玩家算(见 charge/second)。
# ============================================================

execute as @a[scores={zx.pl_t=1..}] at @s run function sweetdream:equipment/staff/polarized_light/tick
