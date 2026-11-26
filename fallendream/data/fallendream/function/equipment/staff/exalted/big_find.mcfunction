tag @e[tag=zx.ex_candidate,distance=0..] remove zx.ex_candidate
tag @e[tag=zx.ex_goal,distance=0..] remove zx.ex_goal
$execute unless entity @e[tag=zx.ex_grave,distance=0..,nbt={UUID:[I;$(g0),$(g1),$(g2),$(g3)]},limit=1] run tag @s remove zx.ex_big
execute unless entity @s[tag=zx.ex_big] run return run function fallendream:equipment/staff/exalted/big_die
$execute at @e[tag=zx.ex_grave,distance=0..,nbt={UUID:[I;$(g0),$(g1),$(g2),$(g3)]},limit=1] run tag @e[type=!#fallendream:no_damage,distance=..16] add zx.ex_candidate
$execute at @e[tag=zx.ex_grave,distance=0..,nbt={UUID:[I;$(g0),$(g1),$(g2),$(g3)]},limit=1] run tag @e[tag=zx.ex_lock,distance=..24] add zx.ex_candidate
# ============================================================
# 目标锁定 (zx.ex_lock) —— 2026-11-01 第二次修「乱索敌 / 一直摇摆」
# ------------------------------------------------------------
# 【上一版为什么还摇摆】我把"优先选没推过的"换成"固定选最近的", 但
#   `sort=nearest` 是**每刻重算**的, 而 big_push 每刻又会把目标推开 0.35 格。
#   于是: 这一刻 A 最近 → 推 A → A 远了 → 下一 tick B 变成最近 → 推 B →
#   B 远了 → 又轮到 A …… 目标在两只之间 20Hz 反复切换, 朝向跟着来回翻。
#   "选最近的"本身没错, 错的是它每刻都重算。
# 【修法】锁定 + 滞回, 两步:
#   ① `zx.ex_lock` 打在选中目标身上, **不随每刻清空**, 下一 tick 优先沿用;
#   ② 锁定目标额外享受 24 格搜索半径(普通候选只有 16 格), 这样它跑到坟场
#      搜索圈的边缘时不会"丢一下、捡回来、再丢" —— 那是第二种抽搐:
#      石像在边界上走一步停一步。
# 只有锁定目标真的没了(死亡/被清/跑出 24 格), 才会重新选最近的一只。
# 【锁的维护】最后两行保证"锁只有当前 goal 持有": 先清掉所有不再当 goal
#   的旧锁, 再把锁给当前 goal。顺序不能反。
# ============================================================
tag @e[tag=zx.ex_lock,tag=zx.ex_candidate,distance=0..,sort=nearest,limit=1] add zx.ex_goal
execute unless entity @e[tag=zx.ex_goal,distance=0..,limit=1] run tag @e[tag=zx.ex_candidate,distance=0..,sort=nearest,limit=1] add zx.ex_goal
tag @e[tag=zx.ex_lock,tag=!zx.ex_goal,distance=0..] remove zx.ex_lock
tag @e[tag=zx.ex_goal,distance=0..] add zx.ex_lock
tag @e[tag=zx.ex_avoid,distance=0..] remove zx.ex_avoid
