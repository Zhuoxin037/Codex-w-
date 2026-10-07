# ============================================================
# sweetdream:equipment/staff/wind_ontheground/burst_self —— 每秒打一轮
# ------------------------------------------------------------
# 【谁调用它】second 里用 @a[scores={zx.wg_burst=1..}] 筛出来的人
# 【为什么要拆成"每秒一轮"】文案的"3 次"绝不能合并成一击:
#   「风声」是按"命中几个生物"叠的, 合并了就只能叠到 1/3 的层数。
#   所以拆成 3 轮, 每轮对"所有术阵中心"各打一圈(见 hit_pass)。
# 【为什么要有这一层】hit_pass 要按 UUID 拼存储路径, 只能用宏;
#   而宏变量只能通过 with storage 传进去 —— 所以先把 UUID 取到手。
# 【收尾】最后一轮打完(计数归 0)才结算:
#   · 风声 > 60 -> bonus(直接把"超出部分"加进「最大魔力值技能倍率」通用乘区)
#   · 有点风声   -> aura(起 20 秒的风声回响)
#   顺序不能反: 风声是边打边叠的, 施法那一刻它还是 0。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work wg.uuid set from storage zx:data self.uuid

# ② 打这一轮(对每个术阵中心各打一圈, 顺便往 zx.wg_sound 里叠风声)
function sweetdream:equipment/staff/wind_ontheground/hit_pass with storage zx:work wg

# ③ 轮数 -1
scoreboard players remove @s zx.wg_burst 1

# ④ 最后一轮结束 -> 结算风声奖励 + 起回响
#    （bonus 已改成"直接进最大魔力值技能倍率通用乘区"，不再是宏函数，普通调用即可）
execute if score @s zx.wg_burst matches ..0 if score @s zx.wg_sound matches 61.. run function sweetdream:equipment/staff/wind_ontheground/bonus
execute if score @s zx.wg_burst matches ..0 if score @s zx.wg_sound matches 1.. run function sweetdream:equipment/staff/wind_ontheground/aura with storage zx:work wg
