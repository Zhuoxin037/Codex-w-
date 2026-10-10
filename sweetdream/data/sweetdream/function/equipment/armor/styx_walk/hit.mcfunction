# ============================================================
# sweetdream:equipment/armor/styx_walk/hit —— 漫步冥河之上: 攻击附噬心目标铺「暗海」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/styx_walk_hit(player_hurt_entity)
# 【执行者】玩家(动手的那个人)
# 【文案】"自身攻击附有「噬心」的生物后在其位置生成一个持续 5 秒、半径 3 格的
#   “暗海”, 之后 8 秒不可再次触发该效果。"
# 【★ 先 revoke 再判 ★】进度是一次性开关, 不撤销就只有第一次能触发
#   (全包进度回调的固定定式, 见 lib/rearm)。
# 【怎么定位"刚才打的那只"】照幻昼 mirage/attack 的成熟办法:
#   · 主判: 生物 NBT 里的 last_hurt_by_player(原版为怪报复玩家记的, 精确到 UUID)
#     + HurtTime 10/9(把"5 秒内打过的其它怪"排掉, 只留刚才这一下)
#   · 兜底: 生物没记字段时退回"16 格内刚挨过打的最近一只"
# 【为什么必须判噬心】文案是"攻击**附有噬心的**生物后" —— 目标不带噬心就什么都不做,
#   而且**不能消耗内置 CD**(白打一下不该把 CD 也搭进去, 所以判噬心在写 CD 之前)。
# 【内置 CD】zx.sw_cd 存"下一次可触发的时刻"(#now + 160 = 8 秒) —— 存到点而不是
#   倒计时, 是因为它要跨"玩家离线/换维度"活着, 而 #now 是持久化的全局刻钟。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/styx_walk_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没戴漫步冥河就没这事
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] run return 0

# ② 内置 CD 未到 → 收工
execute if score @s zx.sw_cd > #now manacore.meta run return 0

# ③ 定位"刚刚被打的那只"
tag @e[tag=zx.sw_t] remove zx.sw_t
execute store result storage zx:work sv.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work sv.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work sv.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work sv.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/armor/styx_walk/find_victim with storage zx:work sv

# 兜底(生物没记 last_hurt_by_player 时)
execute unless entity @e[tag=zx.sw_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:10s},sort=nearest,limit=1] run tag @s add zx.sw_t
execute unless entity @e[tag=zx.sw_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:9s},sort=nearest,limit=1] run tag @s add zx.sw_t
execute unless entity @e[tag=zx.sw_t,limit=1] run return 0

# ④ 目标必须附有「噬心」(不带 = 不触发, 也不吃 CD)
execute unless entity @e[tag=zx.sw_t,tag=zx.status.shixin,limit=1] run return 0

# ⑤ 在**目标的位置**生成暗海(@s 仍是玩家, 归属取自玩家)
execute at @e[tag=zx.sw_t,limit=1] run function sweetdream:equipment/armor/styx_walk/sea_spawn

# ⑥ 记内置 CD(8 秒) + 收尾
scoreboard players operation @s zx.sw_cd = #now manacore.meta
scoreboard players add @s zx.sw_cd 160
tag @e[tag=zx.sw_t] remove zx.sw_t
