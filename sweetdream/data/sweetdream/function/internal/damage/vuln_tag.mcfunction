# ============================================================
# sweetdream:internal/damage/vuln_tag —— 标签的"受击侧加乘"(夜火 / 噬心)
# ------------------------------------------------------------
# 【谁调它】internal/damage/one(在 stg_mul 之后, 且已确认目标带对应标签 + 伤害类型/来源匹配)
# 【执行者】被打的那一只(@s = 目标)   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【做什么】把本次伤害 ×1.15
#     · 夜火: 受到**技能伤害** +15%
#         —— 本包技能类型(sweetdream:skill) **或** 敌方技能(src:"enemy",
#            走 api/enemy_damage)。两个判据在 internal/damage/one 里**互斥**, 不会跑两次。
#     · 噬心: 受到**真实伤害** +15%(type = sweetdream:true_damage)
#   互斥保证了一次调用只从其中一条进来。
# 【★ 底数用**当前** a.num, 不能用 ob.num 快照 ★】
#   stg_mul(升痕)是以 ob.num 为底的; 这里若也以 ob.num 为底, 两者会互相顶掉
#   (后写的那个把前面的覆盖掉, 只生效一个)。本函数的语义是"在升痕算完之后再乘一道",
#   所以读 a.num(stg_mul 已写回)。a.num 是所有调用点都会写的那个 double。
# 【怎么改】double 不能直接乘 -> 分数(x1000) × #115 ÷ #100 再写回, 并重新生成 num_str。
# 【参数缺字段】a.num / a.damage 都没有就直接收工(免得把伤害写成 0)。
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #vt zx.meta 0
execute if data storage zx:work a.num store result score #vt zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #vt zx.meta run data get storage zx:work a.damage 1000
# 【★ R05 整数上界保护(2026-10-10)★】
#   #vt 此刻 = 伤害 ×1000, 下一步就要 ×115。计分板是 **int32**,
#   中间值越过 2,147,483,647 会**回绕成负数** —— 不报错, 只是结果变成天文数字或负值。
#   按原写法, 伤害 ≈ 18,674 就已触界(1000 × 115 = 115,000; 2.1e9 ÷ 115,000 ≈ 18,673)。
#   ★ 为什么是"钳到动态上限"而不是"改成先 ÷100 再 ×115":
#     先除会把 45.67 砍成 45 —— 为防一个极端数值而让**常态**丢掉两位小数精度, 不划算。
#     这里算出 INT32_MAX ÷ 115 当上限, 常态(≤ 18,673 伤害)一行都不改。
scoreboard players set #vt_cap zx.meta 2147483647
scoreboard players operation #vt_cap zx.meta /= #115 zx.meta
execute if score #vt zx.meta > #vt_cap zx.meta run scoreboard players operation #vt zx.meta = #vt_cap zx.meta

scoreboard players operation #vt zx.meta *= #115 zx.meta
scoreboard players operation #vt zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #vt zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
