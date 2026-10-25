# ============================================================
# sweetdream:internal/damage/vuln_ebb —— 「返汐」的受击侧加乘(生物被海浪减速 ⇒ 更疼)
# ------------------------------------------------------------
# 【谁调它】internal/damage/one(已确认目标带 zx.et_e 档位)
# 【执行者】被打的那一只(@s = 目标)   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【★ 文案(逐字)】"生物受到的伤害也将根据在海浪上的移速来增加，每比初始数值慢 10%
#   则其受到的伤害 +3%。"
# 【★ 换算 ★】zx.et_e 每档 = -1% 移速; 每 10 档 = +3% 受伤 ⇒ **每档 +0.3%**,
#   封顶 30 档 = **+9%**（设计稿 §七: "最多 -30% ⇒ +9%"）。
# 【★ 写法照抄 vuln_fcv3(五世恶咒第三世)】包里"按目标身上千分比加乘"的现成先例:
#   · 底数用**当前 a.num**(排在升痕 stg_mul 之后, 语义是"前面算完再乘一道");
#   · 千分比 = 1000 + 档位 ×3;
#   · 乘法前按 INT32_MAX ÷ 倍率 钳位(不钳会在 2^31 处回绕成负数, 且不报错)。
# ★ 单位换算别写反: #ve 是"伤害 ×1000", ×倍率(千分比) 后要 ÷1000 才回到正确量级。
#   (vuln_fcv3 那边是 ÷100, 因为它的倍率是"百分比如 120"; 这里 #vem 是千分比。)
# ============================================================

execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

scoreboard players set #ve zx.meta 0
execute if data storage zx:work a.num store result score #ve zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #ve zx.meta run data get storage zx:work a.damage 1000

# ---- 倍率(千分比) = 1000 + 档位 × 3 ----
scoreboard players set #vem zx.meta 1000
scoreboard players operation #vem3 zx.meta = @s zx.et_e
scoreboard players operation #vem3 zx.meta *= #3 zx.meta
scoreboard players operation #vem zx.meta += #vem3 zx.meta

# 上界保护(INT32_MAX ÷ 倍率)
scoreboard players set #ve_cap zx.meta 2147483647
scoreboard players operation #ve_cap zx.meta /= #vem zx.meta
execute if score #ve zx.meta > #ve_cap zx.meta run scoreboard players operation #ve zx.meta = #ve_cap zx.meta

scoreboard players operation #ve zx.meta *= #vem zx.meta
scoreboard players operation #ve zx.meta /= #1000 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #ve zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
