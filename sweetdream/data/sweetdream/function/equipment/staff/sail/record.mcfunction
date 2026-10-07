# ============================================================
# sweetdream:equipment/staff/sail/record —— 记录最近生物的"四种标记"
# ------------------------------------------------------------
# 【谁调用它】sail/attack 第 ⑤ 步; 【执行者】施法玩家
# 【技能原文(lore 逐字)】每次普攻后都会记录离自身最近的一个生物上所拥有的
#   「渊海」、「流火」、「白昼梦」、「噬心」。
# 【记什么】① 那只生物的 UUID(四个 int, 存玩家计分项 zx.sl_u0..u3)
#             ② 它身上四种标记的**位掩码** zx.sl_mask(1 渊海 / 2 流火 / 4 白昼梦 / 8 噬心)
#             ③ zx.sl_ok = 1(有记录)
#   ★ 为什么用计分项而不是玩家 NBT: 计分项一定写得上, 也一定读得到;
#     marker / 生物的 data.zx 是给实体用的(玩家侧不碰)。
# 【找不到就不动】32 格内一个生物都没有 -> 保留上一次的记录(技能用时会再查一次死活)。
# ============================================================

# ① 找 32 格内最近的一个生物
tag @e[tag=zx.sl_rec,distance=0..] remove zx.sl_rec
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..32,sort=nearest,limit=1] add zx.sl_rec
execute unless entity @e[tag=zx.sl_rec,distance=0..,limit=1] run return 0

# ② 记 UUID 四个 int
execute store result score @s zx.sl_u0 run data get entity @e[tag=zx.sl_rec,limit=1] UUID[0]
execute store result score @s zx.sl_u1 run data get entity @e[tag=zx.sl_rec,limit=1] UUID[1]
execute store result score @s zx.sl_u2 run data get entity @e[tag=zx.sl_rec,limit=1] UUID[2]
execute store result score @s zx.sl_u3 run data get entity @e[tag=zx.sl_rec,limit=1] UUID[3]

# ③ 记四种标记的位掩码
scoreboard players set @s zx.sl_mask 0
execute if entity @e[tag=zx.sl_rec,tag=zx.status.yuanhai,limit=1] run scoreboard players add @s zx.sl_mask 1
execute if entity @e[tag=zx.sl_rec,tag=zx.status.liuhuo,limit=1] run scoreboard players add @s zx.sl_mask 2
execute if entity @e[tag=zx.sl_rec,tag=zx.status.dream,limit=1] run scoreboard players add @s zx.sl_mask 4
execute if entity @e[tag=zx.sl_rec,tag=zx.status.shixin,limit=1] run scoreboard players add @s zx.sl_mask 8

# ④ 有记录了
scoreboard players set @s zx.sl_ok 1

# ⑤ 表现 + 清理临时标记
execute as @e[tag=zx.sl_rec,distance=0..] at @s run particle minecraft:cloud ~ ~1 ~ 0.4 0.5 0.4 0.02 8 normal
tag @e[tag=zx.sl_rec,distance=0..] remove zx.sl_rec
