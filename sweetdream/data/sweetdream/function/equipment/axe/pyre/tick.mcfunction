# ============================================================
# sweetdream:equipment/axe/pyre/tick —— 葬火第二段的 2 秒倒计时(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a[scores={zx.py_d=1..}] at @s run function 本函数
# 【执行者】玩家
# 【做什么】倒计时 -1; 归零就结算第二段(见 boom), 并把 zx.py_x 清 0。
#   ★ 撤除动作必须在本函数里做完 —— 外面筛选是 zx.py_d=1.., 减成 0 之后就不被选中了。
# ============================================================

scoreboard players remove @s zx.py_d 1
execute if score @s zx.py_d matches 1.. run return 0
function sweetdream:equipment/axe/pyre/boom
