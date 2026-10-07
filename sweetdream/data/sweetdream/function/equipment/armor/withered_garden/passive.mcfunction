# ============================================================
# sweetdream:equipment/armor/withered_garden/passive —— 枯枝园的被动(每秒)
# ------------------------------------------------------------
# 【文案】
#   ① 自身魔力值上限 +300。
#   ② 自身 12 格内每有一个"朽木"则自身获得一层抗性提升（最大为 3）。
# 【② 的实现】effect 是覆盖式的: 每秒按当前朽木数重新 give(持续 2 秒),
#   脱下后不再刷新, 2 秒后自然过期 —— 不需要账本。
#   amplifier 必须是命令字面量, 所以按 1/2/3 只分三支(0 只不给)。
# 【为什么对全部玩家跑】魔力上限是差值账本, 脱下那一秒也要有人减回去。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(枯枝园是下界合金护腿, 槽位 armor.legs)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["withered_garden"]}] run scoreboard players set #on zx.meta 1

# ③ 魔力上限 +300 的差值账本
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 300
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.gd_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/withered_garden/apply_mana

# ④ 抗性提升: 12 格内朽木数(封顶 3)
scoreboard players set #wood zx.meta 0
execute store result score #wood zx.meta if entity @e[tag=zx.gw_wood,distance=..12]
execute if score #wood zx.meta matches 4.. run scoreboard players set #wood zx.meta 3
execute if score #on zx.meta matches 1 if score #wood zx.meta matches 1 run effect give @s minecraft:resistance 2 0 true
execute if score #on zx.meta matches 1 if score #wood zx.meta matches 2 run effect give @s minecraft:resistance 2 1 true
execute if score #on zx.meta matches 1 if score #wood zx.meta matches 3 run effect give @s minecraft:resistance 2 2 true
