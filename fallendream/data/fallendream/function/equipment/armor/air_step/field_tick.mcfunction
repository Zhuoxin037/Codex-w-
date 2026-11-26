# ============================================================
# fallendream:equipment/armor/air_step/field_tick —— 超限·踏空: 领域每秒一跳
# ------------------------------------------------------------
# 【谁调用它】
#   · land（落地那一瞬，作为第 1 跳）
#   · lib/second（之后每秒一跳，`as @e[type=marker,tag=zx.as_field] at @s`）
# 【执行者】@s = 领域 marker（执行位置就在领域中心）
# 【文案(lore 逐字)】…在领域内的生物每秒都会受到一次相当于释放者基础攻击力的伤害并被
#   击飞 1 格并获得 2 秒缓慢Ⅰ。每有一个生物受到影响则自身恢复 10 魔力值。
# 【★ 寿命用"秒"不是"刻" ★】zx.as_life = 还剩几跳（5 → 0）。
#   之所以不按刻数: 本函数就是每秒跑一次的, 用秒做单位少一层换算。
# 【★ 先结算再减寿命 ★】这样 5 秒里正好跳 5 次（第 5 跳之后才归零消失）。
# ============================================================

# ① 施放者是谁（marker 上存了 UUID 四段；lib/u_by 零 NBT 反查）
data modify storage zx:work ub set from entity @s data.zx.u
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run kill @s
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 结算这一跳（`as` 不改位置 ⇒ 半径仍然以领域中心为圆心）
#   ★ `positioned ~ ~ ~` 是**空操作**（把执行位置重锚到当前位置），写它只是为了
#     让静态自检认出"这条 as 链上的坐标是故意留在领域中心的"，不是在挪位置。
execute as @a[tag=zx.ub,limit=1] positioned ~ ~ ~ run function fallendream:equipment/armor/air_step/field_hit

# ③ 领域表现
particle minecraft:cloud ~ ~0.1 ~ 1.6 0.1 1.6 0.02 8 normal

# ④ 寿命 -1；归零就消失
scoreboard players remove @s zx.as_life 1
execute if score @s zx.as_life matches ..0 run kill @s
