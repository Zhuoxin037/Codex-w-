# ============================================================
# sweetdream:equipment/armor/styx_walk/passive —— 漫步冥河之上: 被动(每秒)
# ------------------------------------------------------------
# 【谁调用它】second(挂在 #manacore:event/second 上) -> execute as @a 逐个玩家
# 【文案】自身魔力值上限 +210。
# 【为什么对全部玩家跑】这是"穿上加、脱下减"的差值账本 —— 只筛戴头盔的人
#   的话, 摘下那一秒没人执行, 加成永远减不回去(照炉心 furnace_core/passive 的定式)。
# 【暗海相关的一切都不在这里】攻击钩子 -> hit; 每秒结算 -> sea_tick,
#   见 second 的头注释。
# ============================================================

# ① 拿 UUID(账本要按玩家记)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己戴了吗(漫步冥河是下界合金头盔, 槽位 armor.head)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] run scoreboard players set #on zx.meta 1

# ③ 想要的上限 = 210(没戴就是 0), 和账本求差后补差
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 210
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.sw_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/styx_walk/apply_mana
