# ============================================================
# sweetdream:equipment/armor/borrow_fire/unstrip_self —— 5 秒到点: 撤掉自己身上的增益
# ------------------------------------------------------------
# 【执行者】玩家(lib/second 每秒扫 zx.bf_oend 送进来)
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:bf_a_up
attribute @s minecraft:armor_toughness modifier remove sweetdream:bf_t_up
scoreboard players reset @s zx.bf_oend
function sweetdream:equipment/armor/borrow_fire/set_unbonus
