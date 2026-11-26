# ============================================================
# fallendream:lib/thp/apply —— 挂 max_absorption 上限 + 发吸收药水（宏 {amp,mod}）
# ------------------------------------------------------------
# 【宏参数】zx:work thp {amp:<amplifier,0 起>, mod:<≤0 的增量>}
# 【执行者】玩家(@s)
# 【★ 数值只能字面量 ★】`attribute ... modifier add` 与 `effect give` 的等级都
#   吃不了计分项，只能靠宏展开（同 lib/heal_up / lib/mana/* 的写法）。
# ============================================================

$attribute @s minecraft:max_absorption modifier add fallendream:thp_cap $(mod) add_value
$effect give @s minecraft:absorption 60 $(amp) true
tag @s add zx.thp_on
