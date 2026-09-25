# ------------------------------------------------------------
# internal/mana/ban_sec —— 把"秒"换算成 tick
# 【原理】data get 支持缩放参数, 这里传 20(1 秒 = 20 tick),
#         结果四舍五入后存入 #dur。
# 【调用时机】ban 里发现 ticks <= 0 时才会走这里。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.seconds 20
