# ============================================================
# fallendream:equipment/armor/bulwark/off —— 脱下肉盾：撤加成、清基线
# ------------------------------------------------------------
# 抗性由 effect 自己过期（每秒只续 2 秒），这里不主动 clear ——
# 否则和别的抗性来源（迟暮/共情）会互相踩。
# ============================================================

function fallendream:equipment/armor/bulwark/expire
scoreboard players set @s zx.bw_hp 0
