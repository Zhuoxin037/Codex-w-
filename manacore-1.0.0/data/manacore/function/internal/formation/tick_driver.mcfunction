# ============================================================
# internal/formation/tick_driver —— 术阵每秒到期检查
# ------------------------------------------------------------
# 【宏参数】manacore:work.entry {uuid}
# 【时机】每个在线玩家每秒执行一次(由 player/second_macro 调用)。
# 【逻辑】逐个槽位: 有 end 且 end <= #now -> 清槽 + 抛 formation_remove 事件
# 【为什么每秒而不是每刻】到期时间的精度到 tick 就够(冷却/术阵都是秒级
#   或更长), 每秒检查把开销压到 1/20。
# 【永久术阵】没有 end 字段, 永远不会被这里命中。
# ============================================================
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/tick_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/tick_one with storage manacore:work entry
