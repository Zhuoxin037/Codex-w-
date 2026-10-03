# ============================================================
# sweetdream:debug/tg_give —— /trigger zx.dbg_give 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# 【它干什么】调 debug/give_all: 把至今全部的东西装成潜影盒发给你。
#
# 【★ 这条会往你背包里塞东西, 所以刷屏要小心 ★】
#   它每次都会发两个盒子(装备全集 21 件 + 强化材料 7 块)。
#   背包塞不下时 Minecraft 会把盒子掉在你脚下, 不会消失 ——
#   但别站在悬崖/岩浆边按。
# ============================================================

scoreboard players set @s zx.dbg_give 0
tellraw @s [{"text":"[调试] /trigger 收到: 发一套潜影盒(装备全集 + 强化材料)","color":"dark_gray"}]
function sweetdream:debug/give_all
scoreboard players enable @s zx.dbg_give
