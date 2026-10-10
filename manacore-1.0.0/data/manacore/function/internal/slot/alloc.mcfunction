# ------------------------------------------------------------
# internal/slot/alloc —— 分配槽位
# 【策略】先看回收池 manacore:free_slots.list 有没有空槽(有就复用),
#         没有才由 slot/new 开新槽。
# 【为什么要有回收池】#next_slot 只会增长, 如果只增不减, 服运行久了会
#         很快把 max_slots 用光; 回收池让退出的玩家把槽位还回来。
# 【槽位号存在哪】计分板 manacore.slot, 以玩家名为 holder, 天然持久化。
# 【★ F02 修(2026-10-10)】原写法是两条互补的 if/unless **顺序执行** ——
#   from_free 会把回收池里最后一个槽弹走, 于是第二条 unless 当场变真 ⇒ 又跑 new,
#   **刚取到的槽被覆盖**、白丢一格、#next_slot 提前增长(还加速触发溢出)。
#   现在先把"回收池有没有货"冻成一个标记, 再按标记二选一, 分支互斥。
# 【#slot_full】交给 slot/new 置位: 槽位耗尽时不再回绕覆盖别人的索引(F04),
#   而是拒绝分配; 这里先复位, 由 reissue 判它决定要不要登记。
# ------------------------------------------------------------
scoreboard players set #slot_full manacore.meta 0
scoreboard players set #has_free manacore.meta 0
execute if data storage manacore:free_slots list[0] run scoreboard players set #has_free manacore.meta 1
execute if score #has_free manacore.meta matches 1 run function manacore:internal/slot/from_free
execute if score #has_free manacore.meta matches 0 run function manacore:internal/slot/new
