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
# 【★ R05 整数上界保护(2026-10-10)★】#ol_v 此刻是**×1000 定点**, 下一步要 ×#ol_p。
#   计分板是 **int32**, 中间值越过 2,147,483,647 会**回绕成负数** —— 不报错,
#   得到的却是一个天文数字或负值(表现就是"伤害突然变成几百亿/负数")。
#   这里补一道动态上限 = INT32_MAX ÷ #ol_p; 常态数值远不到那个量级, 一行都不受影响。
#   ★ 为什么带上 `matches 1..`: 除数如果是 0, 这条 operation **静默失败**(见坑 85 的
#     除零事故), 乘数是百分比加法的结果、被减到 0 以下是有可能的。
#   ★ 为什么不改成"先 ÷100 再 ×": 那会把 45.67 砍成 45, 让常态丢掉小数精度 ——
#     为防一个极端数值牺牲常态精度不划算(vuln_tag 那条注释里有同样的取舍)。
scoreboard players set #ol_cap zx.meta 2147483647
execute if score #ol_p zx.meta matches 1.. run scoreboard players operation #ol_cap zx.meta /= #ol_p zx.meta
execute if score #ol_p zx.meta matches 1.. if score #ol_v zx.meta > #ol_cap zx.meta run scoreboard players operation #ol_v zx.meta = #ol_cap zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.attack_mul double 0.001 run scoreboard players get #ol_v zx.meta
