# ============================================================
# fallendream:equipment/armor/purge_fire/vuln —— 涤火(超限)：被标记的生物受到的伤害 ×1.20
# ------------------------------------------------------------
# 【谁调它】internal/damage/one（已确认目标带 zx.pf_vuln）
# 【执行者】被打的那一只（@s = 目标）   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【文案(逐字)】"…并使其在该「流火」或「夜火」的持续时间内受到的伤害 +20%…"
# 【★ 为什么另起一份、不改 vuln_tag ★】vuln_tag 里的 115 是夜火/噬心**共用**的写死值,
#   改成 120 会连夜火一起改掉(世咒 vuln_fcv3 当初就是这么分出来的)。
# 【★ 不筛来源 / 类型 ★】文案只写"受到的伤害" —— 玩家平A、技能、真伤、环境都算
#   (与返汐 vuln_ebb 同口径)。
# 【★ 底数用当前 a.num ★】与 vuln_tag 一样, 语义是"前面几道乘完再乘这道"。
# 【定点与溢出】×120 之前按 INT32_MAX ÷ 120 钳位（照搬 vuln_tag 的 R05 做法）。
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #pfv zx.meta 0
execute if data storage zx:work a.num store result score #pfv zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #pfv zx.meta run data get storage zx:work a.damage 1000

scoreboard players set #pfv_m zx.meta 120
scoreboard players set #pfv_cap zx.meta 2147483647
scoreboard players operation #pfv_cap zx.meta /= #pfv_m zx.meta
execute if score #pfv zx.meta > #pfv_cap zx.meta run scoreboard players operation #pfv zx.meta = #pfv_cap zx.meta

#   ★ 单位: #pfv 是"伤害 ×1000", ×120 之后要 ÷100 才回到"伤害 ×1200",
#     最后 ×0.001 写回 double 才是 ×1.20（写成 ÷1000 会变成 ×0.12）。
scoreboard players operation #pfv zx.meta *= #pfv_m zx.meta
scoreboard players operation #pfv zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #pfv zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
data modify storage zx:work a.s2_b_damage set value {n:0,d:1}
data modify storage zx:work a.s2_b_damage set from storage zx:work a.s2_b_num
function fallendream:lib/num/plain
