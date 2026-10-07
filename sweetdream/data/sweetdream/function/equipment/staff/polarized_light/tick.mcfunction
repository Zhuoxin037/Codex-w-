# ============================================================
# sweetdream:equipment/staff/polarized_light/tick —— 光束的一秒
# ------------------------------------------------------------
# 【谁调用它】second 里 `execute as @a[scores={zx.pl_t=1..}] at @s`
#   (执行者 = 施法玩家, at @s 位置也在玩家)
# 【每秒重新锁】"每秒对自身 10 格内离自己最近的一个生物" —— 不是施法时
#   锁死一个, 而是每一秒重新挑最近的目标(怪走了就换目标/没怪就空转一秒)。
# 【伤害口径】当前魔力 ×0.05 → other_mul 通道(基数 = 当前魔力, 框架自动取)。
#   这里不再过超限 mod —— 消耗/冷却在 skill 施法时已经过完了,
#   延迟结算的每秒伤害按描述字面算。
# 【缓慢Ⅱ】给 2 秒、每秒续 —— 比描述的字面多给一点余量, 肉眼上是
#   "被锁定就一直缓着", 光束结束 2 秒后自然消退。
# 【倒计时】放在最后: 先干活再扣, zx.pl_t 减到 0 自然停驱动。
# ============================================================

# ① 锁 10 格内最近的一个生物(#sweetdream:no_damage 含玩家 → 不会锁到自己)
tag @e[tag=zx.pl_lock] remove zx.pl_lock
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..10,sort=nearest,limit=1] add zx.pl_lock

# ② 有目标才算伤害(当前魔力 ×0.05)
execute if entity @e[tag=zx.pl_lock,limit=1] run function sweetdream:equipment/staff/polarized_light/tick_go

# ③ 被锁定的生物获得缓慢Ⅱ(2 秒, 每秒续)
execute as @e[tag=zx.pl_lock] run effect give @s minecraft:slowness 2 1 true

# ④ 光线表现: 施法者眼睛一小簇 + 目标身上一小簇, 中途用 sonid 尘连线感
execute at @s anchored eyes run particle minecraft:end_rod ^ ^ ^0.8 0.06 0.06 0.06 0.0 3 normal
execute as @e[tag=zx.pl_lock] at @s run particle minecraft:end_rod ~ ~1 ~ 0.25 0.25 0.25 0.01 8 normal
execute as @e[tag=zx.pl_lock] at @s run particle minecraft:electric_spark ~ ~1 ~ 0.3 0.3 0.3 0.02 6 normal

# ⑤ 倒计时
scoreboard players remove @s zx.pl_t 1
