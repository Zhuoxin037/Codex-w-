# ============================================================
# sweetdream:equipment/staff/twilight/tw_end —— 8 秒走完: 摘掉铠甲减半修饰符
# ------------------------------------------------------------
# 【谁调用它】tw_tick 第 ③ 步; 【执行者】目标生物
# 【★ 必须 remove】attribute modifier 是**实体数据**, 不摘会永久留在这只生物身上。
#   id 与 tw_lock 的两处 add 必须逐字一致。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:tw_armor
attribute @s minecraft:armor_toughness modifier remove sweetdream:tw_tough
tag @s remove zx.tw_tgt
particle minecraft:squid_ink ~ ~1 ~ 0.4 0.6 0.4 0.05 12 normal
