# ============================================================
# sweetdream:overlimit/api/mod/mm —— arg.max_mana_mul x (1 + 超限伤害)
# ------------------------------------------------------------
# 【★ 动的是"最大魔力值技能倍率"那一档 ★】
#   框架把技能倍率拆成三条通道(见 manacore/internal/damage/calc)。
#   燎原的灼烧、风行的爆发/回响都是"最大魔力 × N", 属于这一条, 所以超限的
#   伤害乘区该乘在 max_mana_mul 上。哪一条通道存在, mod 的主派发就调哪一支 ——
#   燎原/风行不会因为用了哪条通道而漏吃超限。
# 【和 mm 通道的通用加成谁先谁后】两者都作用在同一个最终值上, 且都是**乘**性质
#   (本 mod 乘通道基值; 那一份由 lib/mm_add/hook_calc 进加算池、在 damage_calc
#   事件里对 r.damage 统一乘一次), 交换顺序结果相同 —— 不必调先后。
# 【出参】只改 manacore:in arg.max_mana_mul
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.max_mana_mul 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_d zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.max_mana_mul double 0.001 run scoreboard players get #ol_v zx.meta
