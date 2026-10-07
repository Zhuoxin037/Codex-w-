# ============================================================
# sweetdream:equipment/sword/remelt/melt_end —— 融甲到点, 还原护甲
# ------------------------------------------------------------
# 【执行者】被融甲的生物
# 【★ 一定要摘掉 modifier ★】不摘的话它会永远 0 护甲 —— 和 lib/unfreeze_one 同一个道理。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:remelt
tag @s remove zx.rm_melt
scoreboard players reset @s zx.rm_t
