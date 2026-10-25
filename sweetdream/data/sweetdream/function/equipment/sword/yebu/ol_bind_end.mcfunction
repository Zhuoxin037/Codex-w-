# ============================================================
# sweetdream:equipment/sword/yebu/ol_bind_end —— 摘掉超限·曳步的移速惩罚(执行者 = 那只生物)
# ------------------------------------------------------------
# 【谁调用它】yebu/ol_bind_dim(到期那一刻)
# 【三件事】摘修饰符 / 摘标记 / 清结束刻
#   zx.ybm **不清** —— 那是"这辈子吃过一次"的凭证, 清了就能再吃一次。
# ============================================================
attribute @s minecraft:movement_speed modifier remove sweetdream:yb_bind
tag @s remove zx.yb_bind
scoreboard players reset @s zx.yb_be
