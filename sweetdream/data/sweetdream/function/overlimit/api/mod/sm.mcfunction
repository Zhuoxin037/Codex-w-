# ============================================================
# sweetdream:overlimit/api/mod/sm —— arg.attack_mul x (1 + 超限伤害)
# ------------------------------------------------------------
# 【★ 动的是"基础攻击力倍率"那一档 ★】
#   框架把技能倍率拆成三条通道(见 manacore/internal/damage/calc)。
#   "以基础攻击力结算"的技能(如流光的 ×2 / ×4)走 attack_mul, 所以超限的
#   伤害乘区该乘在这一条上。
# 【和 mm 通道的通用加成谁先谁后】互不相干 —— 那一份(风声 / 忘川彼岸 / 无效)
#   由 lib/mm_add/hook_calc 往加算池的 mm 通道写, 只作用在 max_mana_mul 上。
# 【出参】只改 manacore:in arg.attack_mul
#   (旧名 manacore:in arg.skill_multiplier 框架仍然认, 但本包已全部改用 attack_mul)
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.attack_mul 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_d zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.attack_mul double 0.001 run scoreboard players get #ol_v zx.meta
