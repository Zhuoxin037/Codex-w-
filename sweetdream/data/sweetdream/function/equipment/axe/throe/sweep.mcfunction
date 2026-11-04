# ============================================================
# sweetdream:equipment/axe/throe/sweep —— 痛楚易伤到期摘标签（三维度各跑一次）
# ------------------------------------------------------------
# 【★ 为什么要有它】标签是"还带不带易伤"的唯一依据；不清掉就等于永久 +10%。
# ============================================================

execute as @e[tag=zx.pn_vul,distance=0..] unless score @s zx.pn_until > #now manacore.meta run tag @s remove zx.pn_vul
