# ============================================================
# sweetdream:equipment/sword/myriad/ju_extend —— 居合期间每切换一次: 延长 + 增伤
# ------------------------------------------------------------
# 【执行者】玩家   【谁调用它】两把刀 cast 里"预约换手"那一步之前
# 【文案】期间每使用技能切换【万念】或【千散】都会使该效果延长一秒
#         并使这两把武器下一次技能伤害提升 20%（独立乘区）。
# 【两条都要做, 且只在"已经在居合中"时做】
#   ① zx.mq_ju += 1   —— 延长一秒(和 ju_enter 的"拉满 3 秒"不冲突: 那是进入)
#   ② zx.mq_jb += 1    —— 叠一层"下一次技能伤害 +20%"
# 【★ 独立乘区怎么落地 ★】zx.mq_jb 是**层数**, 真正乘进去在下一次 calc 里:
#   independent_multiplier = 1 + 0.20 × jb(见两把 cast 里的 #mq_im 那段)。
#   用掉之后由 cast 清零 —— 文案说的是"**下一次**技能伤害"。
# ============================================================

execute unless score @s zx.mq_ju matches 1.. run return 0
scoreboard players add @s zx.mq_ju 1
scoreboard players add @s zx.mq_jb 1
execute at @s run particle minecraft:dust{color:[1.0,0.86,0.55],scale:1.0} ~ ~1 ~ 0.8 0.6 0.8 0.02 12 normal
