# ============================================================
# sweetdream:equipment/armor/borrow_fire/unstrip —— 5 秒到点: 撤掉目标身上的削减
# ------------------------------------------------------------
# 【执行者】那只被削过护甲的生物(lib/second 每秒扫 zx.bf_strip 送进来)
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:bf_a_dn
attribute @s minecraft:armor_toughness modifier remove sweetdream:bf_t_dn
tag @s remove zx.bf_strip
scoreboard players reset @s zx.bf_end
