# ============================================================
# fallendream:equipment/armor/spirit_sight/mark_one —— 对"单只有标签的生物"结算
# ------------------------------------------------------------
# 【执行者】那只有五个通用标签之一的生物(8 格内)
# 【基础】发光 3 秒(每秒续, 走出范围自己掉)
# 【超限】再挂缓慢Ⅱ 3 秒、标记 zx.ss_ol + 到期刻 zx.ss_t(= +60 刻),
#   并把护甲值 / 护甲韧性各 −20%(add_multiplied_total)
# 【★ 标记是给受击侧用的】internal/damage/one 只判 zx.ss_ol 一个标签, 不去反查
#   玩家 —— 伤害结算在生物身上跑, 反查玩家是热路径上的大开销(卡顿坑 1)。
# ============================================================

effect give @s minecraft:glowing 3 0 true
execute unless score #ss_ol zx.meta matches 1 run return 0

effect give @s minecraft:slowness 3 1 true
tag @s add zx.ss_ol
scoreboard players operation @s zx.ss_t = #now manacore.meta
scoreboard players add @s zx.ss_t 60
function fallendream:equipment/armor/spirit_sight/strip
