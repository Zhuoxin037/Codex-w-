# ============================================================
# sweetdream:equipment/tool/thunder/pend_go —— 雷鸣: 1 秒到了, 原地再劈
# ------------------------------------------------------------
# 【谁调用它】core/tick: `execute in <维度> as @e[distance=0..,tag=zx.th_pend]
#   at @s if score @s zx.th_due <= #now manacore.meta run function 本函数`
# 【执行者】登记用的 marker(位置 = 1 秒前那道闪电的位置)
# 【顺序】
#   ① 反查释放者 —— marker 上只有 UUID 四位 int, 用 lib/find_by 打 zx.mc_by
#   ② 原地再劈一道闪电 —— ★ summon 时要带上 zx.th_seen ★
#      否则下一刻 strike 会把它当成"新闪电"再触发一次 -> 无限连锁
#   ③ 结算额外伤害(由反查到的玩家归属, 见 bolt_dmg)
#   ④ 收掉 marker(顺带清 zx.mc_by, 不给别人留脏标签)
# ============================================================

data modify storage zx:work th.u0 set from entity @s data.zx.u0
data modify storage zx:work th.u1 set from entity @s data.zx.u1
data modify storage zx:work th.u2 set from entity @s data.zx.u2
data modify storage zx:work th.u3 set from entity @s data.zx.u3
function sweetdream:lib/find_by with storage zx:work th

# ② 第二道闪电(summon 出来的闪电会照常造成原版雷击伤害; 额外伤害在 ③)
summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_seen"]}

# ③ 额外伤害: 执行位置仍是 marker 处, as 只换身份不换位置
execute at @s as @a[tag=zx.mc_by] run function sweetdream:equipment/tool/thunder/bolt_dmg

# ④ 收尾
tag @a remove zx.mc_by
kill @s
