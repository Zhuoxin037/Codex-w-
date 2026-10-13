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
# 【★ 倒计时不在这个函数里 ★】(坑 120)zx.pl_t 的单位恒为「秒」, 由**驱动方**
#   按真实时间扣: 基础版 = second(每 20 刻 = 1 秒)扣 1; 超限版 = half(每 20 刻
#   = 1 秒)扣 1, 同时每 10 刻(0.5 秒)多结算一次。
#   ★ 为什么不能在这里扣: 超限版每 **10 刻**就调一次 tick(0.5 秒节奏)。在这里
#     扣 1 等于把"秒"当成"半秒" —— pl_t=5 只撑 **2.5 秒**, 与 lore 写的
#     "该效果持续 5 秒"差一半(用户 2026-10-11 实测反馈)。干活频率(0.5/1 秒)
#     与持续时间(单位恒为秒)必须彻底解耦。
# ============================================================

# ① 锁目标(#sweetdream:no_damage 含玩家 → 不会锁到自己)
#   基础: 10 格内最近 1 个; 超限: **12 格内最近 3 个**(三道光线各锁一个)。
#   ★ "每秒(基础)/每 0.5 秒(超限)重新挑" —— 不是施法时锁死, 怪走了就换目标。
tag @e[tag=zx.pl_lock] remove zx.pl_lock
execute unless score @s zx.pl_ol matches 1 run tag @e[type=!#sweetdream:no_damage,distance=..10,sort=nearest,limit=1] add zx.pl_lock
execute if score @s zx.pl_ol matches 1 run tag @e[type=!#sweetdream:no_damage,distance=..12,sort=nearest,limit=3] add zx.pl_lock

# ② 有目标才算伤害(当前魔力 ×0.05; 目标 = 全部锁定的, 基础 1 个 / 超限 3 个)
execute if entity @e[tag=zx.pl_lock,limit=1] run function sweetdream:equipment/staff/polarized_light/tick_go

# ③ 被锁定的生物获得缓慢(基础: Ⅱ, 2 秒; 超限: **Ⅲ**, 1 秒 —— 0.5 秒一次的节奏,
#   给 1 秒余量肉眼上就是"被锁定就一直缓着", 光束结束 1 秒后自然消退)
execute unless score @s zx.pl_ol matches 1 run execute as @e[tag=zx.pl_lock] run effect give @s minecraft:slowness 2 1 true
execute if score @s zx.pl_ol matches 1 run execute as @e[tag=zx.pl_lock] run effect give @s minecraft:slowness 1 2 true

# ④ 光线表现: **整条光线**已经挪到 beam(每刻递归铺, 见 beam / beam_step)。
#   原来这里是"玩家眼前一小簇 + 目标身上两簇", 中间是空的 —— 2026-10-09 用户
#   要求"持续射向目标生物", 所以整条线改成每刻铺(粒子寿命 < 1 秒, 每秒铺一次
#   会一闪就没)。
#   这里只留"被锁定目标身上"的一圈命中脉冲(每秒一次), 用来标出"这一秒打的是它"。
execute as @e[tag=zx.pl_lock] at @s run particle minecraft:end_rod ~ ~1 ~ 0.3 0.4 0.3 0.01 8 normal
execute as @e[tag=zx.pl_lock] at @s run particle minecraft:electric_spark ~ ~1 ~ 0.35 0.45 0.35 0.02 6 normal

# ⑤ 【倒计时在驱动方, 不在这里 —— 见文件头坑 120】
