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
#   (2026-10-23 批 K9 新增的两个"随档位落下的参数"也要一并清掉, 免得下一份世咒读残值)
scoreboard players set @s zx.fcv_pct 0
scoreboard players set @s zx.fcv_3v 0
tag @s remove zx.fcv_3
tag @s remove zx.fcv_5
# 第四世破甲: 一并摘标签 + 归零它自己的倒计时(与 armor_uncut 保持一致)
tag @s remove zx.fcv_4
scoreboard players set @s zx.fcv_t4 0
attribute @s minecraft:armor modifier remove sweetdream:fcv4_arm
attribute @s minecraft:armor_toughness modifier remove sweetdream:fcv4_tou
