# ============================================================
# sweetdream:tag/icon_kill_self —— 按"自己的编号"收掉图标
# ------------------------------------------------------------
# 【执行者】被标记的那只生物
# 【为什么要它】换标记 / 摘标记时要先把旧图标收掉, 否则会留下没人认领的孤儿
#   (上一版"重复贴同一个标签就有两个图标"就是这么来的)。
# ============================================================

execute store result storage zx:work ic.id int 1 run scoreboard players get @s zx.icon_id
function sweetdream:tag/icon_kill with storage zx:work ic
