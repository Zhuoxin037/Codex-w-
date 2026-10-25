# ============================================================
# sweetdream:equipment/sword/backflow_tide/push_one —— 把一只生物"向外"推最多 N 格
#   未超限 N=2(原版) / 超限·退汐 N=3(2026-10-23 批 K2)
# ------------------------------------------------------------
# 【谁调用它】dom_one ⑦: execute at <渊海者> as @e[tag=zx.bft_push] run function ...
#   【执行者】被推的那只生物   【位置】它自己
# 【"向外"怎么算】背离被清渊海的那只(zx.bft_src):
#   facing entity <它> feet -> 用局部坐标 ^ ^ ^-1 / ^ ^ ^-2(背后 1 / 2 格)。
#   用 feet 当目标点 —— 两者基本同高, 俯仰角接近 0, 这一下几乎是纯水平,
#   不会把生物顶上天也不会压进地里(同 iridescent/eff_3 的口径)。
# 【为什么不用 Motion 冲量】"格"是距离, 而速度要靠摩擦衰减才能折成距离, 得试值;
#   而且 Motion 只能写具体数值, 写不出"朝某个方向"。
# 【★ 路线必须逐格验空, 且各级按"正好推进 N 格"互斥 ★】
#   未超限 2 级 / 超限 3 级, 每一级都要求"前 N 格全空、第 N+1 格被挡或不存在":
#   撞墙就停在那一步, 这正是"最多"的语义。
#   为什么不写成"连推两次 1 格": 那需要两行**完全相同**的命令, 会被 check.py 的
#   「同文件相邻完全重复」规则判成复制粘贴事故; 而且逐格验空本来就更精确 ——
#   它保证生物绝不穿过挡路的方块。
# 【★ tp 式击退唯一的硬伤】会把生物塞进方块里卡住, 所以每次都要 `if block ... replaceable`。
#   可替换 = 空气/草/水这类(#minecraft:replaceable 方块标签, 同 iridescent/eff_3)。
# ============================================================

# ---- 未超限: 上限 2 格(原版阶梯) ----
# ① 两格都空 -> 推到 2 格外
execute if score #bft_ol zx.meta matches 0 at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet if block ^ ^ ^-1 #minecraft:replaceable if block ^ ^ ^-2 #minecraft:replaceable positioned ^ ^ ^-2 run tp @s ~ ~ ~

# ② 第 2 格被挡、第 1 格是空的 -> 只推 1 格
execute if score #bft_ol zx.meta matches 0 at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet unless block ^ ^ ^-2 #minecraft:replaceable positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ---- 超限·退汐(2026-10-23 批 K2): 上限 3 格 ----
# ★ 这三级必须**按格的连续性**分开判, 不能"先推 3 再落到 2/1 的阶梯":
#   推完之后 @s 位置变了, 每一行都会用**新位置**重算 ^ ^ ^-N —— 上一行刚走过的地方
#   全是空气, 下一行必然又成立, 会一路推出去(实测语义: 3+2+1 = 6 格)。
#   这里每一级的条件是"正好推进 N 格"的充分必要条件, 推完一条之后其余各级都不再成立:
#     · 推 3 后: 新 ^-3 = 原 ^-1 = 空 -> 第 2 级的 `unless ^-3` 假; 不会二次推。
#     · 推 2 后: 新 ^-2 = 原位置   = 空 -> 第 3 级的 `unless ^-2` 假; 不会二次推。
# ③ 三格都空 -> 推到 3 格外
execute if score #bft_ol zx.meta matches 1 at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet if block ^ ^ ^-1 #minecraft:replaceable if block ^ ^ ^-2 #minecraft:replaceable if block ^ ^ ^-3 #minecraft:replaceable positioned ^ ^ ^-3 run tp @s ~ ~ ~

# ④ 第 3 格被挡、前两格空 -> 推 2 格
execute if score #bft_ol zx.meta matches 1 at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet if block ^ ^ ^-1 #minecraft:replaceable if block ^ ^ ^-2 #minecraft:replaceable unless block ^ ^ ^-3 #minecraft:replaceable positioned ^ ^ ^-2 run tp @s ~ ~ ~

# ⑤ 第 2 格被挡、第 1 格空 -> 只推 1 格
execute if score #bft_ol zx.meta matches 1 at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet if block ^ ^ ^-1 #minecraft:replaceable unless block ^ ^ ^-2 #minecraft:replaceable positioned ^ ^ ^-1 run tp @s ~ ~ ~
