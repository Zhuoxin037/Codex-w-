# ============================================================
# fallendream:equipment/staff/firefly_staff/explode —— 萤火触碰后自毁
# ------------------------------------------------------------
# 【执行者】萤火(marker)
# 【文案·原版】"萤火"触碰到生物或射出 12 格后自毁，并对其自身 1 格内的生物
#   造成一次释放者当前魔力值 ×0.04 的伤害。
# 【文案·超限】分三种口径 —— 原文分别写了三个数，这里**分别照做**:
#   · 常规萤火(射出去的)              -> ×0.045   ("✦ 萤火"段)
#   · 追踪萤火(被准星索敌挑中的 5 个) -> ×0.05    ("追踪的萤火伤害提升为…×0.05")
#   · 返回萤火(飞 16 格没命中回身边的) -> ×0.04 且附加「流火」 (主动段)
# 【★ 状态先落到伪玩家/storage 再切人 ★】下面要 `as 释放者` 去算伤害, 一换执行者就
#   读不到萤火身上的标签了 ⇒ 把"是不是追踪/返回"先抄成 #ff_track / #ff_home。
# ============================================================

execute unless entity @s[tag=zx.ff_particle] run return 0

# ① 先拍状态与倍率
scoreboard players set #ff_track zx.meta 0
scoreboard players set #ff_home zx.meta 0
execute if entity @s[tag=zx.ff_homing] run scoreboard players set #ff_track zx.meta 1
execute if entity @s[tag=zx.ff_home] run scoreboard players set #ff_home zx.meta 1
data modify storage zx:work ff.mul set value 0.04
execute if entity @s[tag=zx.ff_ol] run data modify storage zx:work ff.mul set value 0.045
execute if score #ff_track zx.meta matches 1 run data modify storage zx:work ff.mul set value 0.05
execute if score #ff_home zx.meta matches 1 run data modify storage zx:work ff.mul set value 0.04

# ② 摘状态, 收 1 格内的目标
tag @s remove zx.ff_particle
tag @s remove zx.ff_fly
tag @s remove zx.ff_home
tag @s remove zx.ff_homing
tag @s remove zx.ff_track
# 保留 fly_check 已命中碰撞箱的生物，再补上 1 格溅射范围。
execute positioned ~-1 ~-1 ~-1 run tag @e[type=!#fallendream:no_damage,dx=1,dy=1,dz=1] add zx.ff_hit

# ③ 反查释放者 -> 结算伤害(必须在他身上算, "当前魔力"是他的)
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/firefly_staff/damage

# ④ 返回萤火额外附加「流火」
execute if score #ff_home zx.meta matches 1 run data modify storage zx:work ic set value {target:"@e[tag=zx.ff_hit]",mark:"liuhuo"}
execute if score #ff_home zx.meta matches 1 run function fallendream:tag/mark with storage zx:work ic

tag @e[tag=zx.ff_hit,distance=0..] remove zx.ff_hit
particle minecraft:glow ~ ~ ~ 0.3 0.3 0.3 0.03 12 normal
kill @s
