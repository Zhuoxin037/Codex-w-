# @calc: indep
# ============================================================
# sweetdream:equipment/sword/aftersound/hook_indep —— 余响：+5%／个 的下一次技能伤害
# ------------------------------------------------------------
# 【挂哪】data/manacore/tags/function/event/damage_calc.json 的最后一条
#   （必须在 lib/dmg_add_apply 与 profession/hook_independent **之后**）
# 【★ 为什么是独立乘区 ★】文案是"下一次技能伤害 +5%"，乘在三条通道求和之后，
#   不是并进某一条通道做加算（同 愠怒 / 苍蓝星 的口径）。
# 【★ 一次性 ★】结算完当场把 zx.as_n 清 0 —— 所以只吃"下一次"结算。
# 【★ 与面板无关 ★】这里只改 manacore:out r.damage（真实结算值），
#   不碰 zx:work pl，观测镜不会把它算成"常驻倍率"（它本来就是一次性）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.as_n matches 1.. run return 0

# 倍率 = 100 + 5 × n（千分比）
scoreboard players set #as_five zx.meta 5
scoreboard players operation #as_add zx.meta = @s zx.as_n
scoreboard players operation #as_add zx.meta *= #as_five zx.meta
scoreboard players set #as_pct zx.meta 100
scoreboard players operation #as_pct zx.meta += #as_add zx.meta

scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.damage 1000
scoreboard players operation #mp_mul zx.meta = #as_pct zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mp_out zx.meta

scoreboard players set @s zx.as_n 0
