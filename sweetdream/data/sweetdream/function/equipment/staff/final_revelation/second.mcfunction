# ============================================================
# sweetdream:equipment/staff/final_revelation/second —— 终末天启的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【★ 必须写 at @s ★】光柱按玩家朝向铺, 全要相对玩家算(见 scan)。
# ============================================================

execute as @a[scores={zx.fr_t=1..}] at @s run function sweetdream:equipment/staff/final_revelation/tick
