# ============================================================
# sweetdream:equipment/axe/ballad/pick —— 圈出"自身 X 格内最近的 X 个生物"(宏 {x})
# ------------------------------------------------------------
# 【谁调用它】ballad/hit: execute at @s run function ... with storage zx:work bd
# 【执行者】施法者  【位置】施法者所在处
# 【做什么】把符合条件的生物打上 zx.bd_mark, 之后统一结算。
#   ★ 选择器要拼运行期数值(runtime 的 X), 所以必须是宏函数。
#   ★ 调用前先把旧的 zx.bd_mark 清掉(见 hit)。
# ============================================================

$tag @e[type=!#sweetdream:no_damage,distance=0.1..$(x),sort=nearest,limit=$(x)] add zx.bd_mark
