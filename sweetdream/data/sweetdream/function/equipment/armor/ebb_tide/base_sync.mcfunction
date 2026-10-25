# ============================================================
# sweetdream:equipment/armor/ebb_tide/base_sync —— 靴子本体的移速 +10%
# ------------------------------------------------------------
# 【执行者】每个玩家(由 ebb_tide/second ① 广播调用, **不筛穿着的人**)
# 【★ 为什么不筛穿靴子的人 ★】账本是差值的: 只筛穿的人的话, 脱下那一秒没人执行,
#   那 +10% 就永远摘不掉(变成"穿过一次就永久 +10%")。照 resonance/passive 同一条。
# 【★ 为什么走账本 + modifier 而不是物品的 attribute_modifiers 组件 ★】
#   本包所有装备的被动数值都走这条(beach_vein 护甲 / resonance 魔力上限),
#   组件方式会让"穿上/脱下"依赖背包的组件解析, 与现有体系两套口径。
# ============================================================

# ① 该不该有
scoreboard players set #want zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] run scoreboard players set #want zx.meta 1

# ② 与账本比差值（★ 先 add 0 把没分数的补成 0）
scoreboard players add @s zx.et_b 0
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.et_b
execute if score #diff zx.meta matches 0 run return 0

# ③ 摘旧的(挂过才摘 —— remove 不存在的 modifier 会失败)
execute if score @s zx.et_b matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:et_base

# ④ 记新账并按需挂新的
scoreboard players operation @s zx.et_b = #want zx.meta
execute if score @s zx.et_b matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:et_base 0.1 add_multiplied_total
