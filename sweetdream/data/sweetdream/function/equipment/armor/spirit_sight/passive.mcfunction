# ============================================================
# sweetdream:equipment/armor/spirit_sight/passive —— 灵视·每秒
# ------------------------------------------------------------
# 【执行者】玩家(second 用 `as @a at @s` 送进来)
# 【技能原文(lore 逐字)】
#   "自身魔力值上限 +70。自身 8 格内若有带有「渊海」、「流火」、「夜火」、
#    「白昼梦」、「噬心」任一标签的生物则使其发光，且自身每秒恢复一点魔力值。"
# 【四要素】
#   触发 = 每秒判一次(常驻被动)
#   范围 = 自身 8 格内、带五个通用标签之一的生物
#   次数 = 每秒一次
#   时长 = 发光给 3 秒(每秒续一次, 走出范围后自己掉)
# 【口径】"若有…生物"(存在即可) -> 回魔是**每秒固定 1 点**, 不按生物数叠加。
# 【+70 上限不在这里】走 armor_mana/passive。
# ============================================================

# ① 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["spirit_sight"]}] run return 0

# ② 有符合条件的生物吗?(五个通用标签任一)
scoreboard players set #ss_hit zx.meta 0
execute if entity @e[distance=..8,tag=zx.status.yuanhai,limit=1] run scoreboard players set #ss_hit zx.meta 1
execute if entity @e[distance=..8,tag=zx.status.liuhuo,limit=1] run scoreboard players set #ss_hit zx.meta 1
execute if entity @e[distance=..8,tag=zx.status.yehuo,limit=1] run scoreboard players set #ss_hit zx.meta 1
execute if entity @e[distance=..8,tag=zx.status.dream,limit=1] run scoreboard players set #ss_hit zx.meta 1
execute if entity @e[distance=..8,tag=zx.status.shixin,limit=1] run scoreboard players set #ss_hit zx.meta 1
execute unless score #ss_hit zx.meta matches 1 run return 0

# ③ 使其发光(3 秒, 每秒续一次; 隐藏粒子免得一直冒)
execute as @e[distance=..8,tag=zx.status.yuanhai] run effect give @s minecraft:glowing 3 0 true
execute as @e[distance=..8,tag=zx.status.liuhuo] run effect give @s minecraft:glowing 3 0 true
execute as @e[distance=..8,tag=zx.status.yehuo] run effect give @s minecraft:glowing 3 0 true
execute as @e[distance=..8,tag=zx.status.dream] run effect give @s minecraft:glowing 3 0 true
execute as @e[distance=..8,tag=zx.status.shixin] run effect give @s minecraft:glowing 3 0 true

# ④ 自身每秒恢复 1 点魔力值(记进 debug 的"回魔/秒"账本)
scoreboard players add @s zx.regen_extra 1
function sweetdream:equipment/armor/spirit_sight/gain
