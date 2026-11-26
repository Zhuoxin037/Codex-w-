# ============================================================
# fallendream:equipment/staff/firefly_staff/fly_check —— 飞行中每刻: 碰没碰到 / 飞够没有
# ------------------------------------------------------------
# 【命中】1 格判定箱碰到的第一只就爆(判定箱 0.8³, 与文案"触碰到生物"一致)。
# 【飞够】
#   · 原版: 12 格自毁 -> 0.6 格/刻 × 20 刻 ≈ 12 格
#   · 超限: 16 格还没命中就**回身边环绕**(home), 不是自毁
#     直线 0.6/刻 ⇒ 27 刻 ≈ 16.2 格; 追踪 0.8/刻 ⇒ 20 刻 = 16 格
#     ★ 两条分开算: 追踪的步长更大, 用同一个刻数会多飞 5 格。
# ============================================================

scoreboard players add @s zx.ff_age 1
tag @a[tag=zx.ff_owner] remove zx.ff_owner
tag @a[tag=zx.ub,distance=0..,limit=1] add zx.ff_owner
tag @e[tag=zx.ff_hit,distance=0..] remove zx.ff_hit
execute positioned ~-0.4 ~-0.4 ~-0.4 run tag @e[type=!#fallendream:no_damage,tag=!zx.ff_owner,dx=0.8,dy=0.8,dz=0.8] add zx.ff_hit
scoreboard players set #ff_touch zx.meta 0
execute if entity @e[tag=zx.ff_hit,distance=0..] run scoreboard players set #ff_touch zx.meta 1
tag @a[tag=zx.ff_owner] remove zx.ff_owner
execute if score #ff_touch zx.meta matches 1 run return run function fallendream:equipment/staff/firefly_staff/explode

# 原版: 12 格自毁
execute if entity @s[tag=!zx.ff_ol] if score @s zx.ff_age matches 20.. run function fallendream:equipment/staff/firefly_staff/explode
# 超限: 16 格未命中 -> 回身边环绕 8 秒
execute if entity @s[tag=zx.ff_ol] if entity @s[tag=!zx.ff_homing] if score @s zx.ff_age matches 27.. run function fallendream:equipment/staff/firefly_staff/home
execute if entity @s[tag=zx.ff_ol] if entity @s[tag=zx.ff_homing] if score @s zx.ff_age matches 20.. run function fallendream:equipment/staff/firefly_staff/home
