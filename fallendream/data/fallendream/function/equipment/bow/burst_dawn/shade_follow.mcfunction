# ============================================================
# fallendream:equipment/bow/burst_dawn/shade_follow —— 外观载体每刻贴住载具脚底
# ------------------------------------------------------------
# 【谁调用它】core/tick 三维度各一行:
#   execute in <维度> as @e[type=minecraft:item_display,tag=zx.bd_model] at @s
#           run function fallendream:equipment/bow/burst_dawn/shade_follow
# 【执行者】item_display(魂灵之影的外观载体)
# 【★ 为什么不用 ride ★ 2026-11-02 用户实测"一开始在天上, 过了一秒才到地下"】
#   骑乘时乘客的纵向位置由**原版挂载算法**决定(h = 身高 × 挂载比例, 随 scale
#   与版本变化)。我们只能先猜一个 translation 初值, 再事后用读数纠正 ⇒
#   **生成后的第一秒必然是错的**, 靠每秒自校准才落地。这就是"先上天、后落地"。
#   改成独立跟随后: display 位置 = 载具脚底, translation 固定 +0.5(仅补模型
#   自身的半格下沉), 两个量都与挂载高度无关 ⇒ **召唤当刻就贴地**。
# 【每刻而不是每秒】铁傀儡 NoAI、抗击退 1.0, 平时几乎不动; 但被怪打/被爆炸推
#   时仍会位移, 每秒同步会看到模型"拖一下再追上"。每刻 tp 的代价 = 场上每只影
#   一条 tp, 可忽略。
# 【为什么是 2 格】载体恒跟随, 稳态距离恒为 0; 两只影生成间距 3.4 格,
#   2 格半径绝不会串到另一只身上。`limit=1` 不能省(marker 类实体的通病)。
# 【收尸】找不到载具 = 铁傀儡已死(寿命到 / 被打死 / 被当弹药吃掉), 当场收掉自己。
#   这是唯一的收尸路径: 不再骑乘之后"掉下载具"这个判据不存在了。
# ============================================================

execute at @e[tag=zx.bd_shade,distance=..2,sort=nearest,limit=1] run tp @s ~ ~ ~
execute unless entity @e[tag=zx.bd_shade,distance=..2,limit=1] run function fallendream:equipment/bow/burst_dawn/shade_model_die
