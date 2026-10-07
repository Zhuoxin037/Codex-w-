# ============================================================
# sweetdream:overlimit/api/mod/om —— arg.other_mul x (1 + 超限伤害)
# ------------------------------------------------------------
# 【★ 动的是"其他倍率"那一档 ★】
#   框架把技能倍率拆成三条通道(见 manacore/internal/damage/calc)。
#   风行的普攻是"当前魔力 ×0.04", 属于"其他倍率"(基数默认当前魔力),
#   所以超限的伤害乘区该乘在 other_mul 上。
# 【和 mm 通道的通用加成谁先谁后】互不相干 —— 那一份(风声 / 忘川彼岸 / 无效)
#   由 lib/mm_add/hook_calc 往加算池的 mm 通道写, 只作用在 max_mana_mul 上。
# 【出参】只改 manacore:in arg.other_mul
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.other_mul 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_d zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.other_mul double 0.001 run scoreboard players get #ol_v zx.meta
