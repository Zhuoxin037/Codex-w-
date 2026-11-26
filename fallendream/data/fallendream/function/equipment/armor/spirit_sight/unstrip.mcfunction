# ============================================================
# fallendream:equipment/armor/spirit_sight/unstrip —— 走出 8 格后摘掉削减
# ------------------------------------------------------------
# 【执行者】那只生物 【谁调用它】lib/second 三维度扫 zx.ss_t 到期
# 【★ 判据必须带 matches 1.. ★】zx.ss_t 对绝大多数生物恒为 0, 直接写
#   `<= #now` 会把场上每一只都当成"到期"(命缕就是这么坏掉的)。
# ============================================================
attribute @s minecraft:armor modifier remove fallendream:ss_a_dn
attribute @s minecraft:armor_toughness modifier remove fallendream:ss_t_dn
tag @s remove zx.ss_ol
scoreboard players reset @s zx.ss_t
