# ============================================================
# sweetdream:equipment/axe/ballad/ol_pick —— 圈出"X 格内最近的 n 个生物"(宏 {x,n})
# ------------------------------------------------------------
# 【谁调用它】ol_spawn ④
# 【★ 与 pick.mcfunction 的区别】pick 的个数与范围是同一个 X(文案"X 格内的 X 个");
#   音符的个数是 9-X、范围是 X —— 两个数不同, 必须分开传。
# ============================================================

$tag @e[type=!#sweetdream:no_damage,distance=0.1..$(x),sort=nearest,limit=$(n)] add zx.bd_lock
