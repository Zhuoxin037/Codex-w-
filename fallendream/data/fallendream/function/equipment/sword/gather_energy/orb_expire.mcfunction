# ============================================================
# fallendream:equipment/sword/gather_energy/orb_expire —— 超额球 10 秒到期
# ------------------------------------------------------------
# 只清"不占上限的那两个球", 不碰 zx.j_orb / zx.j_prop。
# ============================================================

scoreboard players set @s zx.ge_x 0
scoreboard players set @s zx.ge_end 0
