# ============================================================
# sweetdream:equipment/tool/thunder/on_strike —— 雷鸣: 登记"1 秒后原地再劈"
# ------------------------------------------------------------
# 【执行者】持「雷鸣」的玩家   【执行位置】那道闪电的位置(execute as 不改位置)
# 【为什么用 marker 而不是 schedule】
#   schedule 按函数名排队 + 默认 replace —— 两个玩家(或两道雷)同时命中会互相顶掉,
#   只有一次真的劈出来。marker 一个雷一个, 天然各算各的。
# 【登记了什么】到期时刻 zx.th_due(= #now + 20, 1 秒) + 释放者的 UUID 四位 int
#   (给 pend_go 反查玩家用 —— marker 里存不下玩家引用, 只有 UUID 是稳的)。
# 【★ 用 zx.th_new 找"我刚召唤的那只"】`@n[tag=zx.th_pend]` 会取"最近的",
#   同刻如果有别人的 marker 更近就会写错对象(共享节点串味, RULES 坑 36)。
#   先写成"新"标签、写完立刻摘 —— 同刻最多一个 zx.th_new, 不会认错。
# ============================================================

summon minecraft:marker ~ ~ ~ {Tags:["zx.th_pend","zx.th_new"]}
scoreboard players operation @n[limit=1,tag=zx.th_new] zx.th_due = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.th_new] zx.th_due 20
data modify entity @n[limit=1,tag=zx.th_new] data.zx set value {u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.th_new] data.zx.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.th_new] data.zx.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.th_new] data.zx.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.th_new] data.zx.u3 set from entity @s UUID[3]
tag @n[limit=1,tag=zx.th_new] remove zx.th_new
