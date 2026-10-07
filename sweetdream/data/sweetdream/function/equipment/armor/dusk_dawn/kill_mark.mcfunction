# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark —— 进度入口: 击杀带通用标签的怪
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/dusk_dawn_kill_mark(5 个标签各一条条件)
# 【为什么真正的逻辑在 kill_mark_go】"技能击杀"那条路也要记这笔账(见
#   internal/damage/one), 所以记账逻辑只留一份, 进度和伤害接口都调它。
#   那边用的是差值账本(zx.dd_app), 因此重复调用、两个来源同时命中, 都只会加一次。
# 【★ 超限版要先把"死者"找回来 ★】超限文案是"额外获得 100×X（X 为该生物所有的
#   效果数量）", 而进度的奖励函数拿不到实体 —— 只能按 UUID + Health:0.0f 反查,
#   见 find_dead 顶部的说明。原版是固定 100, 不需要这个。
#   ★ 找不到就按 X=1 走(等于原版行为) —— 宁可少给, 不能给错。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark

scoreboard players set #dd_x zx.meta 1
execute store result storage zx:work v.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work v.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work v.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work v.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/armor/dusk_dawn/find_dead with storage zx:work v
execute if entity @e[tag=zx.dd_d,limit=1] as @e[tag=zx.dd_d,limit=1] run function sweetdream:equipment/armor/dusk_dawn/kill_count
tag @e[tag=zx.dd_d] remove zx.dd_d

function sweetdream:equipment/armor/dusk_dawn/kill_mark_go
