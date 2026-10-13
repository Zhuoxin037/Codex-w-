# ============================================================
# sweetdream:equipment/staff/five_curses/clear —— 清除目标身上的「世咒」
# ------------------------------------------------------------
# 【执行者】目标(生物)
# 【为什么单独一个文件】"清世咒"有两个调用点 —— 终世结算(final)和世咒自然到期
#   (second)。两处要清的东西完全一样(层数/记录/计时/易伤标签/破甲 modifier),
#   各写一遍必然漏项, 所以收成一个入口。
# 【★ modifier 必须显式摘 ★】第四世的护甲减免是加在目标身上的**持久 modifier**,
#   不清就会一直挂着(目标永远少一半护甲) —— 而且它不随存档/维度切换消失。
# ============================================================

scoreboard players set @s zx.fcv_st 0
scoreboard players set @s zx.fcv_rec 0
scoreboard players set @s zx.fcv_t 0
tag @s remove zx.fcv_3
tag @s remove zx.fcv_5
attribute @s minecraft:armor modifier remove sweetdream:fcv4_arm
attribute @s minecraft:armor_toughness modifier remove sweetdream:fcv4_tou
