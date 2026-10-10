# ============================================================
# sweetdream:equipment/axe/charge/strike —— "连劈 N 道闪电"(基础 1 道 / 超限 3 道)
# ------------------------------------------------------------
# 【谁调用它】hit(攻击到生物那一下)
# 【入参】#chg_n zx.meta = 还要劈几道
# 【执行者】玩家   【位置】被打中的那只身上(调用方 at 好了)
# 【为什么单独拆一个文件 + 递归】"劈 3 道"如果在 hit 里直接写三遍同一行,
#   check.py 的"同文件相邻重复行"规则会判为复制粘贴事故 —— 而它确实是**有意的**
#   重复。所以收成一个"数着次数自己调自己"的小循环: 每轮劈一道、计数 -1, 归零即停。
#   ★ 递归是原版 datapack 支持的写法(有深度上限, 这里最多 3 层)。
#   ★ 位置与 @s 在递归里原样继承 —— bolt 要用 ~ ~ ~ 落在目标身上,
#     lib/on_lightning 要用 @s 找"谁的 buff", 两个都对。
# ============================================================

execute if score #chg_n zx.meta matches 1.. run function sweetdream:equipment/axe/charge/bolt
scoreboard players remove #chg_n zx.meta 1
execute if score #chg_n zx.meta matches 1.. run function sweetdream:equipment/axe/charge/strike
