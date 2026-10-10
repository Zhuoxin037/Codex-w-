# ============================================================
# sweetdream:equipment/staff/palette/color_gain —— 把一个颜色写进玩家的颜色槽
# ------------------------------------------------------------
# 【宏/全局入参】#pal_col zx.meta = 颜色码 1(红)/2(黄)/3(蓝)   【执行者】玩家
# 【两个槽】zx.pal_c1(旧) / zx.pal_c2(新)(0 = 空)。
# 【★ 2026-10-08 用户改口径 ★】原话: "我希望调色盘的颜色是会随着普攻命中而顶替掉,
#   而不是说积攒了两个就定型了。"
#   ⇒ 两槽满了**不再丢弃这一笔**, 而是**滚动顶替**: c1 ← c2, c2 ← 新颜色。
#     于是你身上永远是"最近两次命中"的颜色, 每一次普攻都有意义。
#     (之前"满则弃"会让攒满两色之后的所有普攻都白打 —— 那才是"定型"。)
#   ★ "最多同时持有两种颜色"这条文案仍然成立(槽只有两个)。
# 【★ 先判"走哪条路"再写 ★】不能边写边判 —— 写动 c1 之后 c2 的条件就变了。
#   所以先算出 #pal_slot(1/2/3), 再照它写:
#     1 = c1 空, 写 c1
#     2 = c1 有 / c2 空, 写 c2
#     3 = 两个都满, 滚动(c1 ← c2, c2 ← 新)
# ============================================================

# ① 决定走哪条路(此刻的 c1/c2 是"写入之前"的状态)
scoreboard players set #pal_slot zx.meta 0
execute if score @s zx.pal_c1 matches 0 run scoreboard players set #pal_slot zx.meta 1
execute if score @s zx.pal_c1 matches 1.. if score @s zx.pal_c2 matches 0 run scoreboard players set #pal_slot zx.meta 2
execute if score @s zx.pal_c1 matches 1.. if score @s zx.pal_c2 matches 1.. run scoreboard players set #pal_slot zx.meta 3

# ② 写入
#   顺序要紧: 先 c1 ← c2, 再 c2 ← 新 —— 反过来会把刚写进 c2 的新颜色又抄回 c1。
execute if score #pal_slot zx.meta matches 3 run scoreboard players operation @s zx.pal_c1 = @s zx.pal_c2
execute if score #pal_slot zx.meta matches 3 run scoreboard players operation @s zx.pal_c2 = #pal_col zx.meta
execute if score #pal_slot zx.meta matches 2 run scoreboard players operation @s zx.pal_c2 = #pal_col zx.meta
execute if score #pal_slot zx.meta matches 1 run scoreboard players operation @s zx.pal_c1 = #pal_col zx.meta

# ③ 表现(攒上了一笔)
execute if score #pal_slot zx.meta matches 1.. run particle minecraft:witch ~ ~1.2 ~ 0.3 0.3 0.3 0.02 8 normal
