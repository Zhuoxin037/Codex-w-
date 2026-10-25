# ============================================================
# sweetdream:equipment/axe/deep_brine/field_end —— 领域到点: 超限的"超大力拉一次" + 收掉
# ------------------------------------------------------------
# 【谁调用它】field_tick ⑦(计时减到 0 那一刻)
# 【执行者】领域 marker   【位置】领域中心
# 【文案】超限版多了半句: "领域结束时将领域内的生物超大力的拉动一次。"
#   普通版没有这一下 —— 直接 kill。
# 【"超大力"多大】一次推 2.5 格(普通每秒那下是 0.5 格, 5 倍)。
#   同样只在目标格可替换时移动, 免得把生物塞进墙里。
# 【★ 用 zx.db_olm 标记区分 ★】它是 field_one 给超限领域打的 tag;
#   计分项 zx.db_r 只表示"半径多大", 合并不了的普通领域也可能半径变大。
# ============================================================

# ① 半径 -> storage
scoreboard players add @s zx.db_r 0
execute store result storage zx:work dbr.r int 1 run scoreboard players get @s zx.db_r

# ② 超限: 结束那一下超大力拉
function sweetdream:equipment/axe/deep_brine/field_end_go with storage zx:work dbr

# ③ 收掉自己
kill @s
