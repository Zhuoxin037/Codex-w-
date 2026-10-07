# ============================================================
# sweetdream:equipment/armor/eternity/passive —— 永恒: 被动(每秒)
# ------------------------------------------------------------
# 【谁调用它】second -> execute as @a
# 【文案】"自身魔力值上限 +280。自身魔力值若高于 50 点则自身每次消耗了
#   「渊海」「流火」「夜火」「白昼梦」「噬心」任一标签则消耗 50 魔力值并使其再次附着,
#   本次附着的标签不可再触发该效果。"
# 【本条只做魔力上限】"消耗标签补回"那半条不在每秒里 —— 它是"标签被吃掉"那一刻
#   的反应, 挂在**消耗标签的统一入口** sweetdream:lib/mark_consume（耗标签的技能
#   都调它）那一链上, 由 eternity/reclaim 执行。
# 【差值账本的理由同炉心】: 秒级函数每秒都跑, 没有账本就会每秒加一次 +280。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(永恒是下界合金胸甲, 槽位 armor.chest)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["eternity"]}] run scoreboard players set #on zx.meta 1

# ③ 魔力上限 +280(差值账本)
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 280
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.et_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/eternity/apply_mana
