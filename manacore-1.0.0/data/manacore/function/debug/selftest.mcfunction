# ============================================================
# debug/selftest —— 框架功能自检(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】先 /function manacore:debug/on, 再 /function manacore:debug/selftest
# 【它会做什么】用受控数据跑 4 个用例并打印结果:
#   1) 伤害公式: (10x2+5)x1.5=37.5 -> 打印 37500(定点 x1000)
#   2) 冷却: 起 40 tick 冷却后立刻查剩余 -> 应打印 40
#   3) 术阵数量: 创建一个后计数 -> 应为 1
#   4) 术阵上限: 连开 4 个 -> 第 4 个应被拒绝(success=0)
# 【安全】开始前整份备份玩家数据, 结束时原样还原。
# 【前提】需要先完成注册(上线 1 秒后), 否则会提示"尚未注册"。
# ============================================================
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0
function manacore:internal/debug/selftest_resolve with storage manacore:work a
