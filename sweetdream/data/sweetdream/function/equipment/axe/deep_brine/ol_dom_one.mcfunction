# ============================================================
# sweetdream:equipment/axe/deep_brine/ol_dom_one —— 超限版: 消耗一只, 然后继续下一个
# ------------------------------------------------------------
# 【谁调用它】ol_dom_all(入口) / 自己(递归)
# 【执行者】施法者(玩家)  【位置】他所在处 —— 整轮都不会被 dom_one 的 at 污染
# 【每轮做什么】
#   ① 从 zx.db_ysel 里就近取 1 只 -> zx.db_cur
#   ② 取不到 = 候选空了 -> 收工
#   ③ dom_one(消耗「渊海」+ 在其处开领域)
#   ④ 把它从候选里摘掉, 上限 -1
#   ⑤ 上限还有剩就递归
# 【★ 递归行不能带 at @s ★】dom_one 内部用 `at @e[tag=zx.db_cur]` 搬位置; 回来时
#   执行上下文仍是施法者脚下。若在递归行上写 `at @s`, 位置上下文会被上一次搬迁污染
#   (归途的连线递归踩过一模一样的坑)。
# ============================================================

# ① 就近取 1 只
tag @e[tag=zx.db_cur] remove zx.db_cur
execute at @s run tag @e[tag=zx.db_ysel,distance=0..,sort=nearest,limit=1] add zx.db_cur

# ② 候选空了 -> 收工
execute unless entity @e[tag=zx.db_cur,distance=0..,limit=1] run return 0

# ③ 消耗 + 开领域
function sweetdream:equipment/axe/deep_brine/dom_one

# ④ 摘掉已处理的 + 上限 -1
tag @e[tag=zx.db_cur] remove zx.db_ysel
tag @e[tag=zx.db_cur] remove zx.db_cur
scoreboard players remove #db_n zx.meta 1

# ⑤ 还有额度就继续
execute if score #db_n zx.meta matches 1.. run function sweetdream:equipment/axe/deep_brine/ol_dom_one
