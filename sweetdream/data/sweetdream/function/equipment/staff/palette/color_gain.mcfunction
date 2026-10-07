# ============================================================
# sweetdream:equipment/staff/palette/color_gain —— 把一个颜色写进玩家的空槽
# ------------------------------------------------------------
# 【宏/全局入参】#pal_col zx.meta = 颜色码 1(红)/2(黄)/3(蓝)   【执行者】玩家
# 【两个槽】zx.pal_c1 / zx.pal_c2(0 = 空)。
# 【★ 先判"写哪个槽"再写 ★】不能写"先填 c1 再看 c2" —— 填完 c1 之后条件就变了,
#   会连 c2 一起填上(一次攒两色)。所以先算出 #pal_slot(1/2/0), 再照它写。
#   #pal_slot = 0 表示两个槽都满了 -> 不写(文案: 最多同时持有两种颜色)。
# ============================================================

# ① 决定写哪个槽(此刻的 c1/c2 是"写入之前"的状态)
scoreboard players set #pal_slot zx.meta 0
execute if score @s zx.pal_c1 matches 0 run scoreboard players set #pal_slot zx.meta 1
execute if score @s zx.pal_c1 matches 1.. if score @s zx.pal_c2 matches 0 run scoreboard players set #pal_slot zx.meta 2

# ② 写入
execute if score #pal_slot zx.meta matches 1 run scoreboard players operation @s zx.pal_c1 = #pal_col zx.meta
execute if score #pal_slot zx.meta matches 2 run scoreboard players operation @s zx.pal_c2 = #pal_col zx.meta

# ③ 表现(攒上了一笔)
execute if score #pal_slot zx.meta matches 1.. run particle minecraft:witch ~ ~1.2 ~ 0.3 0.3 0.3 0.02 8 normal
