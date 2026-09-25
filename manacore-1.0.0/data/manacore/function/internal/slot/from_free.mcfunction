# ------------------------------------------------------------
# internal/slot/from_free —— 从回收池取一个槽位
# 【做法】free_slots.list[-1] 取最后一个元素(NBT 路径 -1 表示末尾),
#         写进 @s 的 manacore.slot, 然后把它从池子里 remove 掉。
# 【前提】调用方已经用 if data ...list[0] 确认池子非空, 否则 data get 会
#         报错并中断函数。
# ------------------------------------------------------------
execute store result score @s manacore.slot run data get storage manacore:free_slots list[-1]
execute if data storage manacore:free_slots list[-1] run data remove storage manacore:free_slots list[-1]
