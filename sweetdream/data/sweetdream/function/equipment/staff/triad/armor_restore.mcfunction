# ============================================================
# sweetdream:equipment/staff/triad/armor_restore —— 恢复被强化热刀削掉的护甲
# ------------------------------------------------------------
# 【执行者】被削过的那只生物(@s)
# 【为什么必须显式摘】attribute modifier 是**持久**的: 不摘它就会一直挂着,
#   目标永久少护甲 —— 而且换维度、存读档都消不掉。
# 【为什么连 tri_hit 一起清】下次强化要从 0 重新数 3 次, 留着会一上来就"已命中 3 次"。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:tri_fire_arm
attribute @s minecraft:armor_toughness modifier remove sweetdream:tri_fire_tou
scoreboard players set @s zx.tri_hit 0
