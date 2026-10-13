# ============================================================
# sweetdream:upgrade/held_apply —— 把"主手武器上的攻速升级(神经衰弱)"落到玩家身上
# ------------------------------------------------------------
# 【执行者】玩家(由 upgrade/second 以 @a 逐个调用)
# 【为什么是"每秒 + 账本式"】攻击速度是**持续型原版属性**(穿在手上就一直有效),
#   不是"触发一次"的事件型加成 —— 和盔甲的硬化石同一类。换手 / 换武器 / 敲掉升级
#   那一刻目标值会变, 所以每秒对一次账: 只加减"目标值 - 已挂值"的差, 变了才写属性。
#   (和 armor_apply 的 ① 魔力上限 / ③ re/at/hp 完全一套写法。)
# 【目标值从哪来】bonus_held 读**主手**那件的 up 列表, 汇总出 r.aspd(小数)。
#   ×100 换成定点整数(0.1 -> 10)再比账本 —— 账本 zx.up_atks 也是 ×100。
# 【快速短路】主手没升级列表 **且** 账本为 0(从来没挂过) ⇒ 直接 return。
#   这一步值得: 绝大多数玩家手里是没敲升级的装备, 短路掉就省下整趟 bonus_held。
#   ⚠️ 两个 "unless" 必须都在 —— 只判"主手没升级"会在**刚换成没升级的武器**时
#      漏掉"把旧的攻速摘掉"(账本还是 >0, 条件第一半成立就 return 了)。
# 【为什么在主手而不是身上四件】aspd 是武器向字段(updef 的 cat/cat2 = 剑/斧)。
# 【只算"本秒该挂多少"】不追踪是谁给的 —— 账本对不上就按主手现状重挂, 幂等。
# ============================================================

execute unless data entity @s SelectedItem.components."minecraft:custom_data".up unless score @s zx.up_atks matches 1.. run return 0

function sweetdream:upgrade/api/bonus_held

scoreboard players set #as_want zx.meta 0
execute store result score #as_want zx.meta run data get storage zx:out r.aspd 100

scoreboard players operation #diff zx.meta = #as_want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.up_atks
execute unless score #diff zx.meta matches 0 run function sweetdream:upgrade/api/atks_add
