# ------------------------------------------------------------
# internal/mana/percent_calc —— 百分比计算
# 【原理】#pct = #cur x 100 / #max x 10 = (cur/max) 的 x1000 定点表示。
#   #cur 与 #max 都是 x1000 的定点数, 数学上:
#     cur/max x 1000  ==  #cur x 100 / #max x 10
#   拆成"先乘 100 再乘 10"两步, 是为了不让中间量冲到 x1000000 那一档。
# 【溢出说明】直接写 #cur x #scale 的话中间量是 cur x 1000000,
#   cur 超过约 2147 就溢出(表现为百分比突然变成 0 或负数)。
#   拆开后中间量只有 cur x 100000, 上限约 21474。
# 【调用方保证】#max >= 1(即 max_mana >= 0.001), 所以这里不会除零。
# ------------------------------------------------------------
scoreboard players operation #pct manacore.math = #cur manacore.math
scoreboard players operation #pct manacore.math *= #100 manacore.meta
scoreboard players operation #pct manacore.math /= #max manacore.math
scoreboard players operation #pct manacore.math *= #10 manacore.meta
