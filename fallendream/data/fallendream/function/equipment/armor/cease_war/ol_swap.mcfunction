# ============================================================
# fallendream:equipment/armor/cease_war/ol_swap —— 止战(超限)：余勇切到「转化态」
# ------------------------------------------------------------
# 【执行者】玩家   【谁调它】profession/berserker/apply —— "重新获得职业攻击增益"那一刻
# 【文案(逐字)】"重新获得职业攻击增益时，余勇效果改为普通近战命中生物后使其护甲值及
#   护甲韧性 -20% 且自身基础攻击力 +5%，可以叠加三次，持续至余勇效果结束。"
# 【★ 基础版是 end、超限版是"切换" ★】文案用的是"改为" —— 余勇不结束,
#   只是它的"近战奖励"换了内容（回蓝 → 扣护甲/韧性 + 自己加攻）。
# 【★ 不重置时长 ★】"持续至余勇效果结束" ⇒ 结束刻沿用本次余勇的 s2_cw_end，
#   不因为切换而延长或缩短。
# ============================================================

execute unless entity @s[tag=zx.s2_cw] run return 0
scoreboard players set @s zx.s2_cw_x 1

execute at @s run particle minecraft:enchant ~ ~1 ~ 0.4 0.5 0.4 0.05 12 normal
execute at @s run playsound minecraft:block.anvil.use player @a ~ ~ ~ 0.6 1.4
