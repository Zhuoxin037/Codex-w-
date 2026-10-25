# ============================================================
# sweetdream:internal/damage/vuln_fcv3 —— 「五世恶咒·第三世」的受击侧加乘(默认 ×1.20)
# ------------------------------------------------------------
# 【谁调它】internal/damage/one(已确认目标带 zx.fcv_3 且伤害类型是 sweetdream:skill)
# 【执行者】被打的那一只(@s = 目标)   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【做什么】把本次伤害 ×(zx.fcv_3v ÷ 1000) —— 对应文案「第三世: 受到的技能伤害提高
#   20%」; ★ 2026-10-23 批 K9: 超限·主动推进的那一世是 **+40%**, 所以百分比不再写死:
#   挂易伤时 curse_step 已把千分比(120 / 140)拍进目标身上的 zx.fcv_3v, 这里读它;
#   没读到(老存档、或别处挂的标签)就按 **120** 兜底 = 原版行为。
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

# ---- 倍率(千分比): 目标身上的 zx.fcv_3v; 没有就按原版 120 ----
scoreboard players set #v3m zx.meta 120
execute if score @s zx.fcv_3v matches 1.. run scoreboard players operation #v3m zx.meta = @s zx.fcv_3v

# 上界保护(INT32_MAX ÷ 倍率) —— 除数只能进计分项, 所以跟着 #v3m 现算
scoreboard players set #v3_cap zx.meta 2147483647
scoreboard players operation #v3_cap zx.meta /= #v3m zx.meta
execute if score #v3 zx.meta > #v3_cap zx.meta run scoreboard players operation #v3 zx.meta = #v3_cap zx.meta

#   ★ 单位换算别写反: #v3 是"伤害 ×1000", 再 ×120 就是 ×120000, 要 ÷100 才回到
#     "伤害 ×1200" ⇒ 最后 ×0.001 写回 double 时才是 ×1.20。写成 ÷1000 会变成 ×0.12。
scoreboard players operation #v3 zx.meta *= #v3m zx.meta
scoreboard players operation #v3 zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #v3 zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
