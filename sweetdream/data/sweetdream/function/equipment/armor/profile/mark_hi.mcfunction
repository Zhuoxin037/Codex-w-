# ============================================================
# sweetdream:equipment/armor/profile/mark_hi —— 剖面: 生命值**高于** 50% ⇒ 附加「噬心」
# ------------------------------------------------------------
# 【执行者】5 格内的候选生物（由 profile/spend ② 逐个送进来）
# 【判据】Health × 2 > 最大生命值（×1000 定点, 两边同量纲）
#   ★ 换成"×2 再比"而不是"÷2 再比": 定点数的老规矩 —— 除法放最后, 否则常态丢精度。
# 【★ 为什么用 tag/mark 而不是直接打标签 ★】通用状态的唯一入口: 图标、租约、
#   "被消耗时通知装备"（lib/on_consume）全挂在它上面, 剖面自己的收益也要靠那条通知。
# ============================================================

function sweetdream:lib/max_health_score
scoreboard players set #pf_h zx.meta 0
execute store result score #pf_h zx.meta run data get entity @s Health 1000
#   R05: 定点数再乘法前先夹到动态上限 = INT32_MAX ÷ 2（先夹后乘, 不能先除后乘）
scoreboard players set #pf_cap zx.meta 2147483647
scoreboard players operation #pf_cap zx.meta /= #2 zx.meta
execute if score #pf_h zx.meta > #pf_cap zx.meta run scoreboard players operation #pf_h zx.meta = #pf_cap zx.meta
scoreboard players operation #pf_h zx.meta *= #2 zx.meta
execute if score #pf_h zx.meta > #max_hp zx.meta run function sweetdream:tag/mark {target:"@s",mark:"shixin"}
