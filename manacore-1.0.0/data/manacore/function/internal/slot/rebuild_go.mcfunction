# ------------------------------------------------------------
# internal/slot/rebuild_go —— 重建回收池的递归体(1..#max_slots)
# 【宏参数】manacore:work.s.i(由本函数每轮写回, 见下)
# 【终止】#i 超过 #max_slots 就 return(由 rebuild 从 1 起, 扫到并含 #max_slots)。
# 【为什么每轮都要重新写 i】宏参数必须是复合标签里的字段, 而 #i 每轮都在变;
#   不写回的话每一轮渲染出来的都是同一个 i(既有 index/loop 就是这么做的)。
# ------------------------------------------------------------
execute if score #i manacore.meta > #max_slots manacore.meta run return 0
execute store result storage manacore:work s.i int 1 run scoreboard players get #i manacore.meta
execute store result storage manacore:work s.n int 1 run scoreboard players get #i manacore.meta
function manacore:internal/slot/rebuild_one with storage manacore:work s
scoreboard players add #i manacore.meta 1
function manacore:internal/slot/rebuild_go
