# ============================================================
# sweetdream:equipment/staff/surge_ebb/aoe —— 潮涌，潮枯：一次 5 格范围跳
# ------------------------------------------------------------
# 【谁调用它】surge_ebb/second ④⑤：`execute at <释放者/追奉者> run function … with storage zx:work se`
# 【执行者】无要求（位置 = 伤害圆心）
# 【宏参数】zx:work se {v: 伤害点(double), u0..u3: 释放者 UUID 四个 int}
# 【★ 两类目标两种伤害 ★】
#   非玩家生物 → `damage` + parallel_true_damage（真实伤害，绕护甲）
#   玩家       → 走包内伤害管线（普通伤害，吃护甲/乘区），归属给释放者
# 【★ 除释放者外 ★】释放者身上带临时 tag zx.se_c，玩家选择器整段排除它。
# 【★ 击退用 marker 记圆心 ★】`facing entity` 需要一个实体当朝向目标；
#   圆心本身只是个坐标，所以临时 summon 一个 marker，用完立刻 kill。
# ============================================================

# ① 非玩家生物：真实伤害
$damage @e[type=!#sweetdream:no_damage,distance=..5] $(v) sweetdream:parallel_true_damage

# ② 玩家：普通伤害（带归属）
data modify storage zx:work a set value {target:"@a[tag=!zx.se_c,distance=..5]",type:"sweetdream:skill",num:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.u0 set from storage zx:work se.u0
data modify storage zx:work a.u1 set from storage zx:work se.u1
data modify storage zx:work a.u2 set from storage zx:work se.u2
data modify storage zx:work a.u3 set from storage zx:work se.u3
data modify storage zx:work a.num set from storage zx:work se.v
execute unless data storage zx:work a.s2_b_num run data modify storage zx:work a.s2_b_num set value {n:0,d:1}
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 因这一跳受伤的玩家获得加成（不可叠加，12 秒）
execute as @a[tag=!zx.se_c,distance=..5] run function sweetdream:equipment/staff/surge_ebb/buff

# ④ 击退 1 格：朝"远离圆心"的方向，脚部与头部都要是可替换方块
summon minecraft:marker ~ ~ ~ {Tags:["zx.se_src"]}
execute as @e[type=!#sweetdream:no_damage,distance=..5] at @s facing entity @e[tag=zx.se_src,distance=..64,limit=1] feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
kill @e[tag=zx.se_src,distance=..64,limit=1]
