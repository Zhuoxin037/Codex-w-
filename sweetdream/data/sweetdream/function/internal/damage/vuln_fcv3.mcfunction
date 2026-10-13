# ============================================================
# sweetdream:internal/damage/vuln_fcv3 —— 「五世恶咒·第三世」的受击侧加乘(×1.20)
# ------------------------------------------------------------
# 【谁调它】internal/damage/one(已确认目标带 zx.fcv_3 且伤害类型是 sweetdream:skill)
# 【执行者】被打的那一只(@s = 目标)   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【做什么】把本次伤害 ×1.20 —— 对应文案「第三世: 受到的技能伤害提高 20%, 持续 5 秒」。
# 【★ 为什么不复用 vuln_tag ★】vuln_tag 是夜火 / 噬心**共用**的那一份, 里面的 115
#   是写死的; 把 15% 改成 20% 会连夜火一起改掉。所以另起本文件, 只给世咒用。
#   (同理若以后再有"第三种百分比易伤", 也照这样各起一份, 别去改公共那份。)
# 【★ 底数用当前 a.num ★】与 vuln_tag 同一个道理: 排在升痕(stg_mul)之后, 语义是
#   "升痕算完再乘一道"; 若以 ob.num 为底, 两者会互相顶掉, 只生效一个。
# 【定点与溢出】全程按 ×1000 的整数算; ×120 之前先按 INT32_MAX ÷ 120 钳位
#   (照搬 vuln_tag 的 R05 做法 —— 不钳会在 2^31 处回绕成负数, 且不报错)。
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #v3 zx.meta 0
execute if data storage zx:work a.num store result score #v3 zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #v3 zx.meta run data get storage zx:work a.damage 1000

# 上界保护(INT32_MAX ÷ 120)
scoreboard players set #v3_cap zx.meta 2147483647
scoreboard players operation #v3_cap zx.meta /= #120 zx.meta
execute if score #v3 zx.meta > #v3_cap zx.meta run scoreboard players operation #v3 zx.meta = #v3_cap zx.meta

scoreboard players operation #v3 zx.meta *= #120 zx.meta
scoreboard players operation #v3 zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #v3 zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
