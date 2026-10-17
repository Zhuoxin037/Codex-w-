# ============================================================
# sweetdream:equipment/armor/mottle_vein/open —— 杂纹: 开一个 8 秒记录窗口
# ------------------------------------------------------------
# 【谁调用它】consume ①(窗口没开或已过期时)
# 【执行者】消耗者玩家
# 【做两件事】① 清掉上一轮的种类记录 ② 把窗口到期刻设成 #now + 160(8 秒)
# 【★ 为什么先清 ★】上一轮的 zx.mv.* 标签如果留着, 新窗口的第一种会被误判成
#   "已经记过"⇒ 永远凑不满 3 种(而且不报错, 只是这件装备再也不触发)。
# ============================================================

tag @s remove zx.mv.liuhuo
tag @s remove zx.mv.yehuo
tag @s remove zx.mv.shixin
tag @s remove zx.mv.yuanhai
tag @s remove zx.mv.dream

scoreboard players set @s zx.mv_n 0
scoreboard players operation @s zx.mv_end = #now manacore.meta
scoreboard players add @s zx.mv_end 160
