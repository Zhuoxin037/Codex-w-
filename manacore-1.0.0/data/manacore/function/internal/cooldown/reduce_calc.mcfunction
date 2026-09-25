# ------------------------------------------------------------
# internal/cooldown/reduce_calc —— 缩减的实际算式
# 【原理】#dur = #dur(x1000) x (100 - #red/10) / 100
#         #red 是缩减比例 x1000(例如 25% = 250)。
#   #dur 与 #red 都是 x1000 的量, 直接相乘中间量会到 x1000000, 冷却时长超过
#   约 2147 秒就会溢出。所以先把 #red 降一个数量级(250 -> 25), 除数换成 #100,
#   中间量只剩 x100000, 可承受约 21474 秒(6 小时)的冷却。
# 【夹取】#red 超过 1000(100%) 会被压到 1000, 低于 0 会被压到 0,
#         避免出现负冷却(负冷却会让 end < #now, 直接变成"永远就绪")。
# 【精度】#red 降到 1 位小数, 误差最多 0.1%, 对冷却时长没有感知。
# ------------------------------------------------------------
scoreboard players operation #tmp manacore.math = #100 manacore.meta
execute if score #red manacore.math > #scale manacore.meta run scoreboard players operation #red manacore.math = #scale manacore.meta
execute if score #red manacore.math matches ..0 run scoreboard players set #red manacore.math 0
scoreboard players operation #red manacore.math /= #10 manacore.meta
scoreboard players operation #tmp manacore.math -= #red manacore.math
scoreboard players operation #dur manacore.math *= #tmp manacore.math
scoreboard players operation #dur manacore.math /= #100 manacore.meta
