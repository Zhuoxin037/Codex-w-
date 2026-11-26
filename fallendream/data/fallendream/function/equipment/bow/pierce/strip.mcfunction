# ============================================================
# fallendream:equipment/bow/pierce/strip —— 穿孔·超限：削目标护甲与韧性 30%，5 秒
# ------------------------------------------------------------
# 【执行者】被这一箭命中的那只生物
# 【文案】"之后使其护甲值及护甲韧性 -30%, 持续 5 秒。"
# 【口径照抄 borrow_fire/strip】用 `add_multiplied_total` 而不是 add_value ——
#   文案说的是 -30%(比例), 目标本身护甲多高都该按比例掉; add_value 会把重甲削得
#   不痛不痒、布甲削成负值。
# 【★ 重入必须先撤旧 ★】同一只被同一箭打两下 / 被第二箭再打中时, 旧的 modifier
#   还挂着。直接再 add 会变成两条 -30% 叠成 -51%; 而且 zx.pi_end 会被刷新成新的
#   5 秒, 旧的却没人管 ⇒ 到期撤一次之后还剩一条永久 -30%。所以先卸再挂。
# 【计时】zx.pi_end = 到期刻(#now + 100 刻 = 5 秒), lib/second 每秒扫一次撤。
#   存"到期刻"而不是倒计时: 没人每刻扣, 也不会因跨维度/下线而走偏。
# ============================================================

execute if entity @s[tag=zx.pi_strip] run function fallendream:equipment/bow/pierce/unstrip

attribute @s minecraft:armor modifier add fallendream:pi_a_dn -0.3 add_multiplied_total
attribute @s minecraft:armor_toughness modifier add fallendream:pi_t_dn -0.3 add_multiplied_total
scoreboard players operation @s zx.pi_end = #now manacore.meta
scoreboard players add @s zx.pi_end 100
tag @s add zx.pi_strip
