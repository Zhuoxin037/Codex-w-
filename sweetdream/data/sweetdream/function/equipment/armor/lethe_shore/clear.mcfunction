# ============================================================
# sweetdream:equipment/armor/lethe_shore/clear —— 静默清掉「残念」状态
# ------------------------------------------------------------
# 【谁调用它】passive ④(脱下靴子时)
# 【做什么】摘标签 + 移除速度 modifier。
# 【★ 它和 end_lethe 的区别】end_lethe = "自然到期解除", 会打出 AoE 爆发;
#   本函数 = "状态没了但不算解除"(摘下装备) —— 只有清理, 没有伤害。
#   分开是因为"脱下时还吃一发爆发"在文案里没有依据, 也容易被玩家当成 bug。
# 【速度 modifier】remove 一个不存在的 modifier 只会失败记日志, 不会中断函数。
# ============================================================

tag @s remove zx.lethe
attribute @s minecraft:movement_speed modifier remove sweetdream:lethe_speed
