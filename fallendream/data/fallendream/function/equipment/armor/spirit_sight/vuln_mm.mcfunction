# ============================================================
# fallendream:equipment/armor/spirit_sight/vuln_mm —— 超限: 最大魔力类技能伤害 +24%
# ------------------------------------------------------------
# 【执行者】被打的那一只(已确认带 zx.ss_ol, 且这一下是 fallendream:skill 非敌方来源)
# 【入参】#ss_mm ≥ 1(由 internal/damage/one 从 ob.max_mana_mul 读出并判过)
# 【出参】改写 zx:work a.num / a.damage / a.num_str(与 vuln_tag 同一套累积式改写)
# 【★ 为什么不在这里读 ob ★】check 规则规定 zx:work ob 只许 with_from / one / stg_mul
#   碰 —— 别的文件一碰就可能把"同一批伤害的基准"读串。通道读数一律在 one 里做。
# 【★ 底数用当前 a.num】和 vuln_tag 同口径("在升痕/标签加乘之后再乘一道"), 用 ob.num
#   会让两个乘区互相顶掉, 只生效一个。
# 【R05】×1000 之后要 ×124, 先钳到 INT32_MAX ÷ 124。
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #ssd zx.meta 0
execute if data storage zx:work a.num store result score #ssd zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #ssd zx.meta run data get storage zx:work a.damage 1000

scoreboard players set #ssd_cap zx.meta 2147483647
scoreboard players set #ss_124 zx.meta 124
scoreboard players operation #ssd_cap zx.meta /= #ss_124 zx.meta
execute if score #ssd zx.meta > #ssd_cap zx.meta run scoreboard players operation #ssd zx.meta = #ssd_cap zx.meta

scoreboard players operation #ssd zx.meta *= #ss_124 zx.meta
scoreboard players operation #ssd zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #ssd zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
data modify storage zx:work a.s2_b_damage set value {n:0,d:1}
data modify storage zx:work a.s2_b_damage set from storage zx:work a.s2_b_num
function fallendream:lib/num/plain
