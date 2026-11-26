# ============================================================
# fallendream:equipment/bow/pierce/scan —— 贯穿走廊一步(从射手朝被命中者步进)
# ------------------------------------------------------------
# 【谁调用】hook_victim ④(之后自己递归)
# 【执行者】射手(玩家), @s 全程不变
# 【位置】当前走到的那一点; 【朝向】起点由调用方 facing entity 定死, 递归里不再改
# 【每一步】把这一点 1 格内的非玩家生物记为"贯穿路径成员" zx.pi_on。
#   步距 0.5 < 2×1.0, 采样球充分重叠, 合起来就是一条连续约 1 格宽的走廊。
# 【上限】0.5 格 × 64 步 = 32 格, 到点强制收工, 防朝向异常时死循环。
# ============================================================

# ① 本点走廊成员
tag @e[type=!#fallendream:no_damage,distance=..1.0] add zx.pi_on

# ② 步数 +1; 到上限强制收工
scoreboard players add @s zx.pi_step 1
execute if score @s zx.pi_step matches 65.. run return 0

# ③ 沿朝向再走 0.5 格, 递归(朝向继承)
execute positioned ^ ^ ^0.5 run function fallendream:equipment/bow/pierce/scan
