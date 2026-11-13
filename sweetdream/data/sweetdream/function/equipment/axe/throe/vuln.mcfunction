# ============================================================
# sweetdream:equipment/axe/throe/vuln —— 痛楚：「受到伤害提升 10%」的受击侧乘区
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one 的钩子行（目标带 zx.pn_vul 时）
# 【底数】读 zx:work a.num（累积式改写，与 twin/vulnerability 同一口径）
# 【★ 不吃固定伤害 ★】钩子行已带 `unless …{fixed:1b}`（固定值不乘区）。
# ============================================================

execute unless score @s zx.pn_until > #now manacore.meta run return 0
scoreboard players set #mp_mul zx.meta 1100
execute store result score #mp_src zx.meta run data get storage zx:work a.num 1000
function sweetdream:lib/math/mul_permille
execute store result storage zx:work a.num double .001 run scoreboard players get #mp_out zx.meta
function sweetdream:lib/num/plain
