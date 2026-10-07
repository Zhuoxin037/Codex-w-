# ============================================================
# sweetdream:equipment/sword/myriad/ju_boost —— 把居合的独立乘区写进本次伤害
# ------------------------------------------------------------
# 【执行者】玩家   【前置】manacore:in arg 已经 set value 过(其他字段都在)
# 【文案】…使这两把武器**下一次**技能伤害提升 20%（独立乘区）。
# 【★ 独立乘区 = ×(1 + 0.20 × 层数) ★】zx.mq_jb 是"叠了几层", 由 ju_extend
#   每切换一次 +1; 这里是"下一次技能伤害", 所以用掉之后由 cast 清零。
# 【★ 为什么写成 0.01 的比例 ★】计分板是整数, 要变成 double 倍率只能
#   `store result ... double <scale>`, 于是把 (1 + 0.20×jb) 先放大 100 倍存整数。
# ============================================================

scoreboard players set #mq_im zx.meta 100
scoreboard players operation #mq_tmp zx.meta = @s zx.mq_jb
scoreboard players operation #mq_tmp zx.meta *= #20 zx.meta
scoreboard players operation #mq_im zx.meta += #mq_tmp zx.meta
execute store result storage manacore:in arg.independent_multiplier double 0.01 run scoreboard players get #mq_im zx.meta
