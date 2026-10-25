# ============================================================
# sweetdream:equipment/armor/profile/mark_lo —— 剖面: 生命值**低于** 50% ⇒ 附加「噬心」
# ------------------------------------------------------------
# 【执行者】5 格内的候选生物（由 profile/all_effects ② 逐个送进来）
# 【为什么分"高血 / 低血"两段】文案两段的目标筛选是**互补**的:
#   花魔力给**高血**的上噬心（准备打）, 三下打完给**低血**的上噬心（准备收）。
# 【判据】Health × 2 < 最大生命值
# ============================================================

function sweetdream:lib/max_health_score
scoreboard players set #pf_h zx.meta 0
execute store result score #pf_h zx.meta run data get entity @s Health 1000
#   R05: 定点数再乘法前先夹到动态上限 = INT32_MAX ÷ 2（先夹后乘, 不能先除后乘）
scoreboard players set #pf_cap zx.meta 2147483647
scoreboard players operation #pf_cap zx.meta /= #2 zx.meta
execute if score #pf_h zx.meta > #pf_cap zx.meta run scoreboard players operation #pf_h zx.meta = #pf_cap zx.meta
scoreboard players operation #pf_h zx.meta *= #2 zx.meta
execute if score #pf_h zx.meta < #max_hp zx.meta run function sweetdream:tag/mark {target:"@s",mark:"shixin"}
