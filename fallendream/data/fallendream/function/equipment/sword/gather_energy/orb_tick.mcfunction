# ============================================================
# fallendream:equipment/sword/gather_energy/orb_tick —— 超额球到期检查(每秒一次)
# ------------------------------------------------------------
# 【谁调用】equipment/sword/gather_energy/second
# 【执行者】身上有超额球的玩家
# 【口径】ge_end=0 表示"没超上限、不会消失"; 只有写过绝对时刻的才有到期。
# ============================================================

execute if score @s zx.ge_end matches 1.. unless score @s zx.ge_end > #now manacore.meta run function fallendream:equipment/sword/gather_energy/orb_expire
