# ============================================================
# sweetdream:equipment/staff/polarized_light/beam_ol —— 超限: 三道光线(每刻表现)
# ------------------------------------------------------------
# 【谁调用它】beam ⓪ 的分流(执行者 = 施法玩家, 位置/朝向 = 玩家)
# 【文案(超限·偏振光)】"之后自身持续发射**三道光线**并每 0.5 秒对自身 **12 格**内
#   离自己最近的**三个**生物造成一次..." —— 三道 = 三个锁定目标(zx.pl_lock, 见 tick ①)
#   各铺一条。伤害/节奏在 tick/half, 这里只管画线。
# 【怎么铺三条】不知道目标的 UUID, 没法展开三次调用 —— 用"打完一条给那条的目标
#   打 zx.pl_d(已画)戳, 下一轮挑 `tag=!zx.pl_d` 的最近一个"滚动三轮。
#   每条先给目标打 zx.pl_cur(beam_step 的"到达"判据), 铺完摘掉。
# 【为什么 distance=..12】超限锁定范围是 12 格(基础 10); beam_step 的步数上限
#   已放宽到 32 步(0.4 × 32 = 12.8 格)。
# 【宏参数】zx:work pb {u0,u1,u2,u3} = 施法者 UUID 四 int
# ============================================================

# ① 没有任何锁定目标 -> 不铺
execute unless entity @e[tag=zx.pl_lock,distance=..12,limit=1] run return 0

# ② 施法者 UUID 四 int 备进宏节点(打水晶戳要用)
data modify storage zx:work pb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work pb.u0 set from entity @s UUID[0]
data modify storage zx:work pb.u1 set from entity @s UUID[1]
data modify storage zx:work pb.u2 set from entity @s UUID[2]
data modify storage zx:work pb.u3 set from entity @s UUID[3]

# ③ 三条光线: 每轮挑一个还没画过的锁定目标铺一条(beam_one 内部自带步数归零)。
#   ★ 用 #pl_n(本刻已画条数)把三行区分开 —— 三行一字不差会被 check 的"相邻重复"
#     规则拦下; beam_one 每铺一条给 #pl_n +1。
scoreboard players set #pl_n zx.meta 0
execute if entity @e[tag=zx.pl_lock,tag=!zx.pl_d,limit=1] if score #pl_n zx.meta matches 0 run function sweetdream:equipment/staff/polarized_light/beam_one
execute if entity @e[tag=zx.pl_lock,tag=!zx.pl_d,limit=1] if score #pl_n zx.meta matches 1 run function sweetdream:equipment/staff/polarized_light/beam_one
execute if entity @e[tag=zx.pl_lock,tag=!zx.pl_d,limit=1] if score #pl_n zx.meta matches 2 run function sweetdream:equipment/staff/polarized_light/beam_one
tag @e[tag=zx.pl_d] remove zx.pl_d
