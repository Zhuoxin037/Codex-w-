# ============================================================
# fallendream:equipment/bow/pierce/unstrip —— 穿孔·超限：5 秒到点撤掉护甲削减
# ------------------------------------------------------------
# 【执行者】那只被削过护甲的生物(lib/second 每秒扫 zx.pi_strip 送进来)
# ============================================================

attribute @s minecraft:armor modifier remove fallendream:pi_a_dn
attribute @s minecraft:armor_toughness modifier remove fallendream:pi_t_dn
tag @s remove zx.pi_strip
scoreboard players reset @s zx.pi_end
