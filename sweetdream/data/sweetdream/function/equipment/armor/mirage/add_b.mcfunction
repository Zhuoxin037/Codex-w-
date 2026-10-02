# ============================================================
# sweetdream:equipment/armor/mirage/add_b —— 打到带白昼梦的生物: +1 层(上限 10 层 = +20)
# ------------------------------------------------------------
# 【执行者】玩家(由 hit_dream 调进来)
# 【上限 10 层】文案写的是"+2(最多叠加 10 次)", 也就是最多 +20 攻击力。
#   ⚠️ 上限必须判在**加之前**: 满了就一层都不加(总层数和格子都不动),
#   否则"层数封顶但格子还在涨", 到期时会把总层数扣成负数。
# ============================================================

execute if score @s zx.mr_atk2 matches 10.. run return 0

scoreboard players add @s zx.mr_atk2 1
execute if score #mr_rb zx.meta matches 0 run scoreboard players add @s zx.mr_b0 1
execute if score #mr_rb zx.meta matches 1 run scoreboard players add @s zx.mr_b1 1
execute if score #mr_rb zx.meta matches 2 run scoreboard players add @s zx.mr_b2 1
execute if score #mr_rb zx.meta matches 3 run scoreboard players add @s zx.mr_b3 1
execute if score #mr_rb zx.meta matches 4 run scoreboard players add @s zx.mr_b4 1
execute if score #mr_rb zx.meta matches 5 run scoreboard players add @s zx.mr_b5 1
execute if score #mr_rb zx.meta matches 6 run scoreboard players add @s zx.mr_b6 1
execute if score #mr_rb zx.meta matches 7 run scoreboard players add @s zx.mr_b7 1
execute if score #mr_rb zx.meta matches 8 run scoreboard players add @s zx.mr_b8 1
