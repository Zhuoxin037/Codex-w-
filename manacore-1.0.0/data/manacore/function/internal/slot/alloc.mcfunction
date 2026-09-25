# ------------------------------------------------------------
# internal/slot/alloc —— 分配槽位
# 【策略】先看回收池 manacore:free_slots.list 有没有空槽(有就复用),
#         没有才由 slot/new 开新槽。
# 【为什么要有回收池】#next_slot 只会增长, 如果只增不减, 服运行久了会
#         很快把 max_slots 用光; 回收池让退出的玩家把槽位还回来。
# 【槽位号存在哪】计分板 manacore.slot, 以玩家名为 holder, 天然持久化。
# ------------------------------------------------------------
execute if data storage manacore:free_slots list[0] run function manacore:internal/slot/from_free
execute unless data storage manacore:free_slots list[0] run function manacore:internal/slot/new
