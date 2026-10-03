# ============================================================
# sweetdream:overlimit/api/mod/sm —— arg.skill_multiplier x (1 + 超限伤害)
# ------------------------------------------------------------
# 【★ 动的是"技能倍率"那不是"独立乘区" ★】
#   超限写的是"整把武器伤害 +25%", 按包内口径属于普通乘区(和「风声」加成同一档):
#   它要能被 later 的加成正常叠加, 而不是"所有加成算完再统一乘一次"。
# 【和 lib/max_mana_bonus 谁先谁后】两者都是往同一个字段上乘, 交换顺序结果相同。
# 【出参】只改 manacore:in arg.skill_multiplier
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.skill_multiplier 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_d zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.skill_multiplier double 0.001 run scoreboard players get #ol_v zx.meta
