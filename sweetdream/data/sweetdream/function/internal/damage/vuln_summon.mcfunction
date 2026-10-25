# ============================================================
# sweetdream:internal/damage/vuln_summon —— 「被召唤物攻击时受到的伤害 +30%」
# ------------------------------------------------------------
# 【谁调它】internal/damage/one(目标带 zx.svul 且本次伤害带 sm:1b 才调)
# 【执行者】被打的那一只(@s = 目标)
# 【出参】改写 zx:work a.num / a.damage / a.num_str
# 【做什么】把本次伤害 ×1.30
# 【★ 两个条件缺一不可 ★】
#   ① 目标身上有 zx.svul(剩余秒数 ≥ 1)  —— 这是 debuff 本体;
#   ② 本次投递带 sm:1b                   —— 这是"来自召唤物"的凭据。
#   只判 ① 会让玩家的平A/技能也吃 30%; 只判 ② 会让全场召唤物都打得更疼。
# 【写在 one 的哪一步】和 vuln_tag(夜火/噬心)/ vuln_fcv3(世咒) 并列,
#   都在 deal **之前**, 以**当前** a.num 为底再乘一道(乘区次序不影响结果)。
# 【和 vuln_tag 的关系】两条是**不同的** debuff: 同时存在时各乘一次
#   (×1.15 × 1.30), 属于预期叠加(与"夜火 + 噬心"同族)。
# 【★ 底数用 a.num, 不用 ob.num ★】理由同 vuln_tag: 这里语义是"前面几道算完再乘一道"。
# 【★ int32 上界保护 ★】#vs 是伤害 ×1000, 再 ×130 会越过 2,147,483,647,
#   动态钳一道上限(常态数值远到不了, 见 vuln_tag 的同类注释)。
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #vs zx.meta 0
execute if data storage zx:work a.num store result score #vs zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #vs zx.meta run data get storage zx:work a.damage 1000

scoreboard players set #vs_cap zx.meta 2147483647
scoreboard players operation #vs_cap zx.meta /= #130 zx.meta
execute if score #vs zx.meta > #vs_cap zx.meta run scoreboard players operation #vs zx.meta = #vs_cap zx.meta

scoreboard players operation #vs zx.meta *= #130 zx.meta
scoreboard players operation #vs zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #vs zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
