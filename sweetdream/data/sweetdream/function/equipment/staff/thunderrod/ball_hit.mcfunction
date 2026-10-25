# ============================================================
# sweetdream:equipment/staff/thunderrod/ball_hit —— 引雷针普攻的命中回调(宏)
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(`function $(hit) with entity @s data`)
#   —— 所以本文件**是宏函数**, 宏源 = 法球自己的 data({uuid,dmg,style,u0..u3,hit})
# 【执行者】法球, 位置 = 命中点
# 【文案】「每次普攻命中后，1 秒后在目标所在位置降下一道闪电。」
#   ★ 2026-10-13 起不再有"当前魔力 ×0.03"的伤害(会超模, 用户拍板砍掉)。
# 【★ 为什么登记 marker 而不是直接落雷 ★】文案是"1 秒后"。用 marker 记一个
#   **到期时刻**(zx.tr_due = now + 20), 由 core/tick 每刻判(精度到 tick);
#   ★ 不能用 schedule: 两人同时施法会互相顶掉(默认 replace, 先例
#     tool/thunder/pend_go 的注释)。
# 【★ 为什么"目标所在位置"= 命中点 ★】文案说的是命中那一刻它站的地方;
#   marker 钉在命中点不动, 目标跑开也照样劈那儿(这正是"定点落雷"的手感)。
# 【★ 为什么不带倍率 ★】double 走宏会渲染成 "0.03d"(NBT 类型后缀), 塞进命令
#   参数会炸(见 projectile/ball/fire 的朝向说明) ⇒ 普攻 ×0.03 / 主动 ×0.05
#   各写一份静态函数(bolt_atk / bolt_skill), 不靠宏传数字。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.tr_pend","zx.tr_new"],data:{zx:{tr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}

# 超限·引雷针: **两道**雷(2026-10-23 批 K9)。
#   ★ 第二道要**错开 10 tick**: 原版受击后有 10 tick 无敌帧, 同一刻连劈两道的话
#     第二道打不进伤害(只看见两道雷光、只吃一次伤害) ⇒ 第二道挪到 now+30(1.5 秒)。
#     用 tag zx.tr_d2 区分两批 marker(zx.tr_new 是"刚生成还没设到期刻"的通用标签)。
execute if data entity @s data{ol:1b} run summon minecraft:marker ~ ~ ~ {Tags:["zx.tr_pend","zx.tr_new","zx.tr_d2"]}
execute if data entity @s data{ol:1b} run data modify entity @e[tag=zx.tr_d2,tag=zx.tr_new,distance=..3,limit=1] data.zx.tr set from entity @e[tag=!zx.tr_d2,tag=zx.tr_new,distance=..3,limit=1] data.zx.tr

execute as @e[tag=zx.tr_new,tag=!zx.tr_d2,distance=..3,limit=1] run scoreboard players operation @s zx.tr_due = #now manacore.meta
execute as @e[tag=zx.tr_new,tag=!zx.tr_d2,distance=..3,limit=1] run scoreboard players add @s zx.tr_due 20
execute as @e[tag=zx.tr_new,tag=zx.tr_d2,distance=..3,limit=1] run scoreboard players operation @s zx.tr_due = #now manacore.meta
execute as @e[tag=zx.tr_new,tag=zx.tr_d2,distance=..3,limit=1] run scoreboard players add @s zx.tr_due 30
tag @e[tag=zx.tr_new,distance=..3] remove zx.tr_new

# 引雷针"指着"命中点的一丝电光(预约感, 真正的雷 1 秒后到)
particle minecraft:electric_spark ~ ~0.3 ~ 0.15 0.15 0.15 0.02 8 normal
playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.35 1.9
