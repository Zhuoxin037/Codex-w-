# ============================================================
# fallendream:equipment/armor/spirit_sight/strip —— 护甲值 / 护甲韧性 −20%
# ------------------------------------------------------------
# 【执行者】那只生物
# 【★ 先 remove 再 add ★】modifier 是实体数据, 同一 id 重复 add 会**叠加**;
#   每秒续一次 ⇒ 不先摘就会一秒比一秒更脆。先摘后挂 = 幂等。
# 【比例削减必须用 add_multiplied_total】-0.2 = ×(1−0.2); 用 add_value 是减 0.2 点
#   护甲值(对高护甲怪几乎无感, 与文案"−20%"完全不同)。
# 【摘的时候】见 unstrip.mcfunction。
# ============================================================
attribute @s minecraft:armor modifier remove fallendream:ss_a_dn
attribute @s minecraft:armor_toughness modifier remove fallendream:ss_t_dn
attribute @s minecraft:armor modifier add fallendream:ss_a_dn -0.2 add_multiplied_total
attribute @s minecraft:armor_toughness modifier add fallendream:ss_t_dn -0.2 add_multiplied_total
