# ============================================================
# fallendream:equipment/staff/firefly_staff/spawn —— 普攻后在身周生成一个「萤火」(宏 {uuid, ol})
# ------------------------------------------------------------
# 【上限】原版 10 个 / 超限 12 个(文案"最多 12 个")。
#   ★ 计数口径不变: 场上属于**自己**的全部萤火(idle + 飞行中 + 环绕中)都算,
#     所以环绕那 8 秒里普攻也会被上限挡住 —— 与"最多 N 个"一致。
# 【档位】ol 从 storage 读(不是宏参数): 少一个宏参数就少一处"漏传整函数作废"。
#   档位落在两处: 实体 NBT(data.ol, 给 tick 读) + 标签 zx.ff_ol(给碰撞/伤害分档)。
# ============================================================

scoreboard players set #ff_n zx.meta 0
$execute store result score #ff_n zx.meta if entity @e[tag=zx.ff_particle,distance=0..,nbt={data:{owner:"$(uuid)"}}]
scoreboard players set #ff_lim zx.meta 10
# ★ 先清零再取值: `data get` 没取到时 store 不执行, 不先清零会**沿用上一次的档位**
scoreboard players set #ff_c zx.meta 0
execute store result score #ff_c zx.meta run data get storage zx:work firefly.ol
execute if score #ff_c zx.meta matches 1 run scoreboard players set #ff_lim zx.meta 12
execute if score #ff_n zx.meta >= #ff_lim zx.meta run return 0
summon minecraft:marker ~ ~1 ~ {Tags:["zx.ff_particle","zx.ff_idle","zx.ff_new"],data:{angle:0,ol:0,u0:0,u1:0,u2:0,u3:0}}
$data modify entity @e[tag=zx.ff_new,distance=0..,limit=1] data.owner set value "$(uuid)"
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.ol int 1 run scoreboard players get #ff_c zx.meta
execute if score #ff_c zx.meta matches 1 run tag @e[tag=zx.ff_new,distance=0..] add zx.ff_ol
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players set #ff_angle zx.meta 36
scoreboard players operation #ff_n zx.meta *= #ff_angle zx.meta
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.angle int 1 run scoreboard players get #ff_n zx.meta
tag @e[tag=zx.ff_new,distance=0..] remove zx.ff_new
