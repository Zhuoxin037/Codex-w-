# ============================================================
# sweetdream:tag/follow_one —— 跟踪用的取编号层
# ------------------------------------------------------------
# 【执行者】带 zx.tagged 的生物
# 【为什么要拆】图标的选择器是 zx.icon_<编号>, 编号在生物自己的计分项上,
#   要拼进选择器就必须走宏 —— 所以先把编号搬进节点再调用宏函数。
# ============================================================

execute store result storage zx:work ic.id int 1 run scoreboard players get @s zx.icon_id
function sweetdream:tag/icon_tp with storage zx:work ic
