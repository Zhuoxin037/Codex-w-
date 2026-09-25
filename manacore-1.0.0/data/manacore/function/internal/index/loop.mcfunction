# ------------------------------------------------------------
# internal/index/loop —— 索引遍历的递归体
# 【宏参数】manacore:work.a.i = 本轮槽位号
# 【流程】1) 若 index."i" 存在 -> 交给 index/visit(由 ctrl.mode 分派)
#         2) #idx 自增 -> 写回 work.a.i -> 只要 #idx <= #next_slot 就递归
# 【参数为什么写在 work.a 里】宏参数必须是一个复合标签; 我们统一约定
#         "当前宏参数 = manacore:work.a", 调用形式固定为
#         function <id> with storage manacore:work a
#         这样每个函数只需要关心自己的字段, 不再到处传 storage 路径。
# 【注意】调用带 with 的形式时, 该复合里的字段就是占位符的来源, 缺字段
#         会导致整个函数渲染失败, 所以每轮都要把 i 重新写进去。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run function manacore:internal/index/visit with storage manacore:index "$(i)"
scoreboard players add #idx manacore.meta 1
execute store result storage manacore:work a.i int 1 run scoreboard players get #idx manacore.meta
execute if score #idx manacore.meta <= #next_slot manacore.meta run function manacore:internal/index/loop with storage manacore:work a
