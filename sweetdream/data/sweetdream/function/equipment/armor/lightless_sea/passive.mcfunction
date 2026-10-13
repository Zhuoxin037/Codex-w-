# ============================================================
# sweetdream:equipment/armor/lightless_sea/passive —— 无光海的被动(每秒)
# ------------------------------------------------------------
# 【文案】
#   ① 自身魔力值上限 +200。
#   ② 自身 8 格内若有缓慢效果或附加了「渊海」效果的生物, 则每秒都会使其
#      3 格内的全部生物获得 2 秒虚弱Ⅲ, 且每影响一个生物都会为自身回复
#      5 魔力值且自身基础攻击力 +1, 若自身 3 秒内没有持续该效果则清空该加成。
# 【② 的口径】
#   · "影响一个生物" = 本秒被(所有源生物的 3 格圈)盖到的生物总数 ——
#     用共享标签 zx.ls_hit 去重(两个源的圈重叠时同一只只算一次)。
#   · 攻击力加成 = 快照型: 本秒影响 n 个 → 加成 = n(差值账本调平);
#     n 归 0 后**不清**, 进入 3 秒宽限(zx.ls_t 从 3 每秒递减), 宽限内保持
#     原值, 断供满 3 秒才清零; 期间再来目标立刻跟随新的 n。
#   · 回魔是即时的(每秒 n×5), 不占账本。
# 【"有缓慢效果"的判定】实体 NBT active_effects 列表里出现 minecraft:slowness(1.20.2+)
#   (列表按子序列匹配, 任意等级/时长的缓慢都算)。
# 【为什么对全部玩家跑】两本账都是差值账本, 脱下那一秒也要有人减回去。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(无光海是下界合金靴子, 槽位 armor.feet)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lightless_sea"]}] run scoreboard players set #on zx.meta 1

# ③ 魔力上限 +200 的差值账本
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 200
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ls_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/lightless_sea/apply_mana

# ④ 圈"源生物": 8 格内带缓慢 或 渊海(两遍各打一次标签, 天然去重)
tag @e[tag=zx.ls_src] remove zx.ls_src
tag @e[tag=zx.ls_hit] remove zx.ls_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,nbt={active_effects:[{id:"minecraft:slowness"}]}] add zx.ls_src
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,tag=zx.status.yuanhai] add zx.ls_src

# ⑤ 圈"受影响": 每个源的 3 格内全部生物(标签幂等 = 去重)
execute as @e[tag=zx.ls_src] at @s run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.ls_hit
scoreboard players set #n zx.meta 0
execute store result score #n zx.meta if entity @e[tag=zx.ls_hit]

# ⑥ 宽限计时: 有影响 → 刷新 3; 穿着没影响 → 递减; 脱下 → 清 0
execute if score #on zx.meta matches 1 if score #n zx.meta matches 1.. run scoreboard players set @s zx.ls_t 3
execute if score #on zx.meta matches 1 unless score #n zx.meta matches 1.. if score @s zx.ls_t matches 1.. run scoreboard players remove @s zx.ls_t 1
execute unless score #on zx.meta matches 1 run scoreboard players set @s zx.ls_t 0

# ⑦ 攻击力账本: 有影响跟随 n; 宽限内(n=0 且 ls_t>0)保持原值; 断供满/脱下 → 0
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 if score #n zx.meta matches 1.. run scoreboard players operation #want zx.meta = #n zx.meta
execute if score #on zx.meta matches 1 unless score #n zx.meta matches 1.. if score @s zx.ls_t matches 1.. run scoreboard players operation #want zx.meta = @s zx.ls_buf
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ls_buf
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/lightless_sea/apply_atk

# ⑧ 结算: 虚弱Ⅲ 2 秒 + 每只回 5 魔力(有影响且穿着才跑)
execute if score #on zx.meta matches 1 if score #n zx.meta matches 1.. run function sweetdream:equipment/armor/lightless_sea/impact
