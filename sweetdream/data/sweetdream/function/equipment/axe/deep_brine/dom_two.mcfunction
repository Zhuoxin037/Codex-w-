# ============================================================
# sweetdream:equipment/axe/deep_brine/dom_two —— 普通版: 就近取最多 2 个「渊海」逐个消耗
# ------------------------------------------------------------
# 【谁调用它】cast ⑨(深溟不是超限版时)
# 【执行者】施法者(玩家)  【位置】他所在处
# 【为什么单独成函数】超限版要"全部", 两套循环形状不同; 拆开之后 cast 只需一行分派。
#   ★ 老代码原样搬来 —— 这两段"就近 1 个 + 从候选里摘掉 + 再来一次"的写法别改,
#     它是靠"摘掉已处理的"来实现"第 2 个自然轮到下一个"的。
# ============================================================

# 第 1 个
tag @e[tag=zx.db_cur] remove zx.db_cur
execute at @s run tag @e[tag=zx.db_ysel,distance=0..,sort=nearest,limit=1] add zx.db_cur
execute if entity @e[tag=zx.db_cur,distance=0..,limit=1] run function sweetdream:equipment/axe/deep_brine/dom_one
tag @e[tag=zx.db_cur] remove zx.db_ysel
tag @e[tag=zx.db_cur] remove zx.db_cur

# 第 2 个(第 1 个已从候选里摘掉, 所以"就近 1 个"自然轮到下一个)
execute at @s run tag @e[tag=zx.db_ysel,distance=0..,sort=nearest,limit=1] add zx.db_cur
execute if entity @e[tag=zx.db_cur,distance=0..,limit=1] run function sweetdream:equipment/axe/deep_brine/dom_one
tag @e[tag=zx.db_cur] remove zx.db_ysel
tag @e[tag=zx.db_cur] remove zx.db_cur
