# ============================================================
# sweetdream:equipment/armor/intravenous_pump/passive —— 静脉泵的被动(以玩家身份)
# ------------------------------------------------------------
# 【文案上写的】① 自身魔力值上限 +120   ② 自身生命值为满时每秒恢复 3 点魔力
#
# 【怎么认"穿没穿"】execute if items entity @s armor.chest <物品>[custom_data={...}]
#   ★ custom_data 这里写的是**整份**内容: {zx:["intravenous_pump","chestplate"]}
#     为什么不只写 ["intravenous_pump"]? 因为该写法是"精确比对"——
#     少写一段就永远匹配不上, 而且不报错、不闪红, 纯静默失效。
#     (踩过一次: 只写了一段, 结果整套装备效果一点反应都没有。)
#     >>> 以后改 give 里的 custom_data, 这里必须同步改 <<<
#
# 【加成只能加差值】面板里每一项只是一个数, 没有"加成层"。所以用
#   zx.pump_mana 这个计分项当账本, 记"本来源已经加过多少", 换装时只补差额。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 穿没穿
scoreboard players set #pump_on zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data={zx:["intravenous_pump","chestplate"]}] run scoreboard players set #pump_on zx.meta 1

# ③ 魔力上限 +120
scoreboard players set #want zx.meta 0
execute if score #pump_on zx.meta matches 1 run scoreboard players set #want zx.meta 120
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.pump_mana
scoreboard players set #src zx.meta 1
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/intravenous_pump/apply_mana

# ④ 生命值满 -> 每秒回 3 点魔力
#   生命值用 scale 1 取整(Health 是浮点, 直接截断会把 27.99 当成 27, 满血误判)
execute store result score #hp zx.meta run data get entity @s Health 1
execute store result score #hp_max zx.meta run attribute @s minecraft:max_health get
scoreboard players set #full_hp zx.meta 0
execute if score #hp_max zx.meta matches 1.. if score #hp zx.meta >= #hp_max zx.meta run scoreboard players set #full_hp zx.meta 1
execute if score #pump_on zx.meta matches 1 if score #full_hp zx.meta matches 1 run function sweetdream:equipment/armor/intravenous_pump/regen_mana
