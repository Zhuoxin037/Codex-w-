# ------------------------------------------------------------
# internal/slot/new —— 开一个新槽位
# 【做法】全局计数器 #next_slot 自增 1, 再复制给该玩家的 manacore.slot。
# 【上限保护】超过 #max_slots 时调用 slot/overflow, 计一次溢出并回绕到 1。
#         回绕可能撞上在线的玩家, 但那时索引会因 uuid 不匹配而被判定
#         "槽位失效", 该玩家会在下一秒重新分配, 属于自愈行为。
# 【想扩容】把 config.settings.max_slots 调大后 reload; 遍历用的是
#         #next_slot 而不是固定常量, 所以不需要改任何函数。
# ------------------------------------------------------------
scoreboard players add #next_slot manacore.meta 1
execute if score #next_slot manacore.meta > #max_slots manacore.meta run function manacore:internal/slot/overflow
scoreboard players operation @s manacore.slot = #next_slot manacore.meta
