# ============================================================
# fallendream:equipment/armor/mottle_vein/open —— 杂纹: 开一个记录窗口
# ------------------------------------------------------------
# 【谁调用它】consume ①(窗口没开或已过期时)
# 【执行者】消耗者玩家
# 【做三件事】① 清掉上一轮的种类记录(含"叠加第二次"的那一套)
#             ② 把窗口到期刻设成 #now + 160(基础 8 秒) / +320(超限 16 秒)
#             ③ 把待兑现标记清掉
# 【★ 为什么先清 ★】上一轮的 zx.mv.* 标签如果留着, 新窗口的第一种会被误判成
#   "已经记过"⇒ 永远凑不满 3 种(而且不报错, 只是这件装备再也不触发)。
# 【★ 窗口长度分档 ★】基础 8 秒 / 超限 16 秒（文案: "记录接下来 16 秒内消费过的不同种类"）。
# ============================================================

# ① 清上一轮（第一层 + 第二次叠加的标记都要清）
tag @s remove zx.mv.liuhuo
tag @s remove zx.mv.yehuo
tag @s remove zx.mv.shixin
tag @s remove zx.mv.yuanhai
tag @s remove zx.mv.dream
tag @s remove zx.mv2.liuhuo
tag @s remove zx.mv2.yehuo
tag @s remove zx.mv2.shixin
tag @s remove zx.mv2.yuanhai
tag @s remove zx.mv2.dream

scoreboard players set @s zx.mv_n 0
scoreboard players set @s zx.mv_pend 0

# ② 窗口长度: 基础 8 秒 / 超限 16 秒
scoreboard players operation @s zx.mv_end = #now manacore.meta
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run scoreboard players add @s zx.mv_end 160
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run scoreboard players add @s zx.mv_end 320
