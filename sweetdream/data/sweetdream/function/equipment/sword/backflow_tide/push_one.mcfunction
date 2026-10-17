# ============================================================
# sweetdream:equipment/sword/backflow_tide/push_one —— 把一只生物"向外"推最多 2 格
# ------------------------------------------------------------
# 【谁调用它】dom_one ⑦: execute at <渊海者> as @e[tag=zx.bft_push] run function ...
#   【执行者】被推的那只生物   【位置】它自己
# 【"向外"怎么算】背离被清渊海的那只(zx.bft_src):
#   facing entity <它> feet -> 用局部坐标 ^ ^ ^-1 / ^ ^ ^-2(背后 1 / 2 格)。
#   用 feet 当目标点 —— 两者基本同高, 俯仰角接近 0, 这一下几乎是纯水平,
#   不会把生物顶上天也不会压进地里(同 iridescent/eff_3 的口径)。
# 【为什么不用 Motion 冲量】"格"是距离, 而速度要靠摩擦衰减才能折成距离, 得试值;
#   而且 Motion 只能写具体数值, 写不出"朝某个方向"。
# 【★ 两格路线必须逐格验空 ★】
#   ① 第 1 格与第 2 格**都**可通行 -> 直接推到 2 格外。
#   ② 第 2 格不可通行(但第 1 格可以) -> 只推到 1 格外。
#   ③ 第 1 格就不可通行 -> 一步都不推(= 原文的"**最多** 2 格")。
#   为什么不写成"连推两次 1 格": 那需要两行**完全相同**的命令, 会被 check.py 的
#   「同文件相邻完全重复」规则判成复制粘贴事故; 而且逐格验空本来就更精确 ——
#   它保证生物绝不穿过挡路的方块。
# 【★ tp 式击退唯一的硬伤】会把生物塞进方块里卡住, 所以每次都要 `if block ... replaceable`。
#   可替换 = 空气/草/水这类(#minecraft:replaceable 方块标签, 同 iridescent/eff_3)。
# ============================================================

# ① 两格都空 -> 推到 2 格外
execute at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet if block ^ ^ ^-1 #minecraft:replaceable if block ^ ^ ^-2 #minecraft:replaceable positioned ^ ^ ^-2 run tp @s ~ ~ ~

# ② 第 2 格被挡、第 1 格是空的 -> 只推 1 格
execute at @s facing entity @e[tag=zx.bft_src,distance=0..,limit=1] feet unless block ^ ^ ^-2 #minecraft:replaceable positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
