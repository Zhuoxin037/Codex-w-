# ============================================================
# sweetdream:equipment/axe/thunderclap/domain_fx —— 威霆: 半径 6 的「领域」边界表现
# ------------------------------------------------------------
# 【谁调用它】thunderclap/field_tick(每秒一次)   【执行者】术阵 marker   【位置】术阵处
# 【为什么要有它】文案(2026-10-07 玩家改稿)写"生成一个术阵**并生成一个半径 6 格的领域**" ——
#   领域是"落雷判定"的真相(bolt 里 `distance=..6` 就是它), 玩家得看得见边界才知道站哪。
# 【怎么画】圆环用 12 个采样点围出来(每 30° 一个, 半径 6)。
#   ★ 为什么不用 `particle ... delta` 铺一片: 那是个**方块**不是圆, 边界会看着比 6 格远。
#   ★ 点距 = 2×6×sin(15°) ≈ 3.1 格, 比粒子本身的可见尺寸大不少 —— 是"虚线环"效果,
#     不追求实线(每秒描一遍, 够用了)。
# 【本函数在"每维度各跑一次"的链上】不出现裸 @e。
# ============================================================

# ① 圆环: 12 个采样点(每 30°)
execute rotated 0 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 30 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 60 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 90 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 120 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 150 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 180 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 210 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 240 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 270 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 300 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal
execute rotated 330 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.35 0.1 0.35 0.02 2 normal

# ② 领域内一层极淡的电雾(让人知道"里面"是有效范围, 而不只是有个边框)
particle minecraft:electric_spark ~ ~0.5 ~ 5.0 0.4 5.0 0.01 6 normal
