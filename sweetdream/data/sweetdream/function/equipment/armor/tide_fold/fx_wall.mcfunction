# ============================================================
# sweetdream:equipment/armor/tide_fold/fx_wall —— 水墙的一次粒子表现
# ------------------------------------------------------------
# 【执行者】墙 marker(@s)  【位置/朝向】at @s（位置 = 墙心脚底, 朝向 = 生成时 yaw）
# 【怎么铺】沿墙的**本地 X 轴**（= 视线的右方向, 也就是墙的长边）取 5 个采样点,
#   与 wall_tick 的判定用**同一组点** —— 表现和判定对不上是这类领域最常见的翻车点。
# 【为什么不用 fill】会真的改方块 —— 领域类一律纯 marker + 粒子（范式速查第 ① 条）。
# ============================================================

execute at @s positioned ^-4 ^1.2 ^ run particle minecraft:falling_water ~ ~ ~ 0.15 1.1 0.15 0.06 5
execute at @s positioned ^-2 ^1.2 ^ run particle minecraft:falling_water ~ ~ ~ 0.15 1.1 0.15 0.06 5
execute at @s positioned ^0 ^1.2 ^ run particle minecraft:falling_water ~ ~ ~ 0.15 1.1 0.15 0.06 5
execute at @s positioned ^2 ^1.2 ^ run particle minecraft:falling_water ~ ~ ~ 0.15 1.1 0.15 0.06 5
execute at @s positioned ^4 ^1.2 ^ run particle minecraft:falling_water ~ ~ ~ 0.15 1.1 0.15 0.06 5

execute at @s positioned ^-2 ^1.2 ^ run particle minecraft:bubble ~ ~ ~ 0.15 1.1 0.15 0.02 4
execute at @s positioned ^0 ^1.2 ^ run particle minecraft:bubble ~ ~ ~ 0.15 1.1 0.15 0.02 4
execute at @s positioned ^2 ^1.2 ^ run particle minecraft:bubble ~ ~ ~ 0.15 1.1 0.15 0.02 4
