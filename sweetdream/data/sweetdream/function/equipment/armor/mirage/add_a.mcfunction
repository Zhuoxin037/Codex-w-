# ============================================================
# sweetdream:equipment/armor/mirage/add_a —— 受伤一次: +1 层(不设上限)
# ------------------------------------------------------------
# 【执行者】玩家(由 hurt 调进来; 套装判定在调用方做完了)
# 【为什么要写两处】总层数 zx.mr_atk1 用来算加成, 环形格子用来记"这层什么时候
#   到期"。两者必须在同一个条件下一起加 —— 只加一个会导致"层数掉不干净"或
#   "加成还在但格子已经空了"。
# 【不设上限】文案里 +2 那条写了"最多叠加 10 次", +1 这条**没写**, 用户明确
#   说了这条"不受限": 受到伤害就 +1, 而不是把时间刷回去。
# ============================================================

scoreboard players add @s zx.mr_atk1 1
execute if score #mr_ra zx.meta matches 0 run scoreboard players add @s zx.mr_a0 1
execute if score #mr_ra zx.meta matches 1 run scoreboard players add @s zx.mr_a1 1
execute if score #mr_ra zx.meta matches 2 run scoreboard players add @s zx.mr_a2 1
execute if score #mr_ra zx.meta matches 3 run scoreboard players add @s zx.mr_a3 1
execute if score #mr_ra zx.meta matches 4 run scoreboard players add @s zx.mr_a4 1
execute if score #mr_ra zx.meta matches 5 run scoreboard players add @s zx.mr_a5 1
