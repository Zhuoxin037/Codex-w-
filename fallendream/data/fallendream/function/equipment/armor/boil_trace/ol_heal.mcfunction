# ============================================================
# fallendream:equipment/armor/boil_trace/ol_heal —— 超限·沸痕：恢复 15% 最大生命值
# ------------------------------------------------------------
# 【执行者/受益者】玩家（穿超限沸痕、刚挨过火伤的那个人）
# 【文案(逐字)】"…并为自身恢复 15% 生命值…"
# 【★ 走 lib/heal 的整点入口 ★】包里改不了玩家的 Health（data/execute store 对玩家
#   一律拒绝），所有"恢复 N 点"最后都进 lib/heal（#heal_pt = 整点数）。
# 【★ 15% 向下取整、保底 1 点 ★】lib/heal 只吃整数；取整"只会少不会多"（半个心以内）。
# ============================================================

function fallendream:lib/max_health_score
execute unless score #max_hp zx.meta matches 1.. run return 0

# 最大生命(毫点) × 0.15 —— mul_permille 自带分段长乘, 不会越过 int32
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 150
function fallendream:lib/math/mul_permille

# #mp_out 是"毫点" ⇒ 除 1000 换成整点数
scoreboard players set #bt_k zx.meta 1000
scoreboard players operation #mp_out zx.meta /= #bt_k zx.meta
execute unless score #mp_out zx.meta matches 1.. run scoreboard players set #mp_out zx.meta 1
scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
function fallendream:lib/heal
