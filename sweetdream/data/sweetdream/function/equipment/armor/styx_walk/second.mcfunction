# ============================================================
# sweetdream:equipment/armor/styx_walk/second —— 漫步冥河之上的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【两件事】
#   ① 每个玩家: 被动(魔力上限账本)
#   ② 每片暗海: 结算一次(sea_tick)
# 【★ 不再清 zx.in_sea(2026-10-06 修 bug)★】旧版这里每秒摘一次"在暗海里"的标签,
#   本意是"离开暗海就断开连续停留计时, sea_tick 会给还在的重新打上"。但 sea_tick
#   就是**同一秒**里紧跟着跑的 —— sea_enter 判到的永远是"刚被清空", 于是每秒把
#   踏入时刻重置一次, 停多久都到不了 40 刻(玩家报"停留 2 秒没结附噬心")。
#   连续性现在改用**时刻差** zx.sw_last 判, 那个标签整个退役。
# 【★ 这里的 @e 不带位置参数 = 有意为之 ★】暗海可能分布在不同维度, 必须一次搜全。
#   (RULES 坑 55 说的是"每个维度各写一遍会重复处理", 这里只写一遍, 全域搜是正确的。)
# 【暗海是 item_display 实体】不是计分板 —— 位置/寿命/归属/动画都在实体自己身上,
#   多玩家、多片暗海天然各算各的, 不需要共享节点分账。
#   (2026-10-06 从 marker 换成 item_display, 为的是有贴图海面, 见 sea_spawn)
# ============================================================

function sweetdream:lib/in_bak

# ① 被动
execute as @a at @s run function sweetdream:equipment/armor/styx_walk/passive

# ② 暗海每秒结算(执行者 = 暗海本体, 位置 = 暗海中心)
execute as @e[tag=zx.sea] at @s run function sweetdream:equipment/armor/styx_walk/sea_tick

function sweetdream:lib/in_restore
