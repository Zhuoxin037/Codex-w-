# ============================================================
# sweetdream:equipment/armor/lethe_shore/apply_speed —— 残念: 基础速度翻倍
# ------------------------------------------------------------
# 【谁调用它】begin(进入残念时) —— 解除时走 end_lethe 里的 remove。
# 【执行者】玩家
# 【"基础速度翻倍"怎么写】modifier 的 add_multiplied_base 是
#   最终速度 = 基础值 × (1 + Σ倍率)，所以填 1.0 就是 ×(1+1) = 2 倍基础速度。
#   语法照抄包里**已实装并验证过**的 lib/freeze(它用 -1.0 add_multiplied_base
#   把速度压到 0): `attribute <目标> minecraft:movement_speed modifier add
#   <命名空间id> <值> <运算>` —— 1.21 起没有 name 参数, id 必须带命名空间。
# 【★ 先 remove 再 add = 幂等 ★】同名 modifier 重复 add 不会叠加、也不会静默
#   顶替(会失败), 所以先无条件 remove 一次再 add —— remove 一个不存在的
#   modifier 只会失败并记日志, 不会中断函数(运行时失败 ≠ 语法错误)。
#   这样"残念被打断又重新进入"也不会留下两份加成。
# ============================================================

attribute @s minecraft:movement_speed modifier remove sweetdream:lethe_speed
attribute @s minecraft:movement_speed modifier add sweetdream:lethe_speed 1.0 add_multiplied_base
