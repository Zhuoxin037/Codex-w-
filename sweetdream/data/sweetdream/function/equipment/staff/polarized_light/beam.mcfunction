# ============================================================
# sweetdream:equipment/staff/polarized_light/beam —— 「持续光线」的每刻表现(入口)
# ------------------------------------------------------------
# 【谁调用它】core/tick:
#     execute as @a[scores={zx.pl_t=1..}] at @s run function .../beam
#   (执行者 = 施法玩家; 位置 / 朝向 = 玩家)
# 【文案】"之后自身**持续发射一道光线**..." —— 2026-10-09 用户要求把这道光线真正
#   做出来。原实现只有"玩家眼前一小簇 + 目标身上两簇"(见 tick ④), 中间是空的,
#   看着不像一条射出去的光。
# 【为什么必须每刻】粒子寿命 < 1 秒; 每秒只铺一次 = 一闪就没了。这和终末天启
#   光柱当初是同一个坑(见 final_revelation/tick 的说明) —— 表现层一律挂每刻。
# 【形状】沿"眼睛 -> 锁定目标(眼睛)"这条直线每 0.4 格撒一颗亮粒子。
#   写法照 bow/cold_crow/step 的"positioned 递归": 朝向在入场时用 facing 定死,
#   递归里只前进、不改向, 所以这一路是**直线**。
# 【★ 顺带干一件机制上的事 ★】光线上每一点都查"有没有自己人的共鸣水晶",
#   有就给它打 zx.ch_beam 戳 —— 共鸣的 pass_set 每刻读这个戳来触发
#   (用户 2026-10-09: "这两个都是持续发射光束, 所以穿过水晶且可以触发")。
#   "自己人的" = 水晶的 data.zx.ch.u0..u3 与施法者一致, 与"法球穿过"同一套归属判据。
# 【宏参数】zx:work pb {u0,u1,u2,u3} = 施法者 UUID 四 int
# 【★ 超限分流(超限·偏振光) ★】三道光线 = 三个锁定目标各铺一条 —— 见 beam_ol。
#   分流放最前(分流后 return, 基础路径整段不跑)。
# ============================================================

# ⓪ 超限版走 beam_ol(三道光线, 距离 12)
execute if score @s zx.pl_ol matches 1 run function sweetdream:equipment/staff/polarized_light/beam_ol
execute if score @s zx.pl_ol matches 1 run return 0

# ① 没有锁定目标(或者目标已经跑出 10 格) -> 这一束光不铺
#    (锁定目标是每秒重挑的, 见 tick ①; 这里每刻读同一个标签)
execute unless entity @e[tag=zx.pl_lock,distance=..10,limit=1] run return 0

# ② 施法者 UUID 四 int 备进宏节点(打水晶戳时要拼进选择器, 只能走宏)
data modify storage zx:work pb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work pb.u0 set from entity @s UUID[0]
data modify storage zx:work pb.u1 set from entity @s UUID[1]
data modify storage zx:work pb.u2 set from entity @s UUID[2]
data modify storage zx:work pb.u3 set from entity @s UUID[3]

# ③ 步数归零(全局假玩家计数, 每轮必须重置 —— 同 cold_crow/step 的 #cc_step)
scoreboard players set #pl_st zx.meta 0

# ④ 从眼睛出发, 面朝目标(眼睛), 交给 beam_step 递归步进
#    ★ anchored eyes 让 ^ 的基准落在眼睛上; facing 定死方向后递归继承
#    ★ 先给目标打 zx.pl_cur(beam_step 的"到达"判据读它, 与超限三道光同一套)
tag @e[tag=zx.pl_lock,limit=1] add zx.pl_cur
execute anchored eyes facing entity @e[tag=zx.pl_lock,distance=..10,limit=1] eyes run function sweetdream:equipment/staff/polarized_light/beam_step with storage zx:work pb
tag @e[tag=zx.pl_cur] remove zx.pl_cur
