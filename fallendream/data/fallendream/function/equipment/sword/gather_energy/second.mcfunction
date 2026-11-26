# ============================================================
# fallendream:equipment/sword/gather_energy/second —— 聚能超额球每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【筛选】只处理身上有超额球的玩家, 没球的开销为零。
# ============================================================

function fallendream:lib/in_bak

execute as @a[scores={zx.ge_x=1..}] run function fallendream:equipment/sword/gather_energy/orb_tick

function fallendream:lib/in_restore
