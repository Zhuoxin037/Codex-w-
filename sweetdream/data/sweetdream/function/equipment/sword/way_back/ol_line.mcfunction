# ============================================================
# sweetdream:equipment/sword/way_back/ol_line —— 超限·归途 的连线采样(自递归)
# ------------------------------------------------------------
# 【执行上下文】位置 = 当前采样点；朝向 = **已经指向归途灯**(由调用方的 facing 定好)
# 【做什么】给当前点 1.7 格内的生物挂 zx.wb_line, 然后沿朝向前进 2.5 格递归一次。
# 【★ 为什么用自递归 + 到灯就停 ★】
#   玩家 20 秒能跑多远完全不确定(灯可能在 5 格, 也可能在 60 格外)。写死"前方 N 格球串"
#   必然是"近的打得到、远的打不到"; 自递归按固定间距铺满, 多长都能盖住。
#   包内先例: boss/fireaxe/leap/measure 的 `positioned ^ ^ ^0.25 run function 自己`。
# 【★ 上限 28 步 = 70 格 ★】20 秒跑不到更远; 同时它也是"朝向退化(两点重合)"时的
#   死循环保险 —— 虽然调用方已经用 distance=..2.5 先挡过一道。
# 【★ 递归那一行绝对不能带 `at @s` ★】
#   `at @s` 会把执行位置打回玩家脚下 —— 采样点永远停在起点, 变成"在同一点挂 28 次标签"。
#   只写 `positioned`, 它才是"在上一个采样点的基础上再前进 2.5 格"。
# 【★ 间距 2.5 / 半径 1.7 ★】直线上相邻球心距 2.5、半径 1.7 > 2.5/2 ⇒ 连线无空隙;
#   侧向还能容忍 1.7 格偏移(和"前方 N×M"那套球串口径一致)。
# ============================================================

execute if score #wb_step zx.meta matches 28.. run return 0
tag @e[type=!#sweetdream:no_damage,distance=..1.7] add zx.wb_line
execute if entity @e[tag=zx.wb_tgt,distance=..2.5,limit=1] run return 0
scoreboard players add #wb_step zx.meta 1
execute facing entity @e[tag=zx.wb_tgt,limit=1] feet positioned ^ ^ ^2.5 run function sweetdream:equipment/sword/way_back/ol_line
