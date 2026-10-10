# ============================================================
# manacore:internal/index/find_uuid_loop —— 逐格找"这是谁的槽"
# ------------------------------------------------------------
# 【为什么要它】以前认人只看"玩家自己计分项上的槽号", 那个分数一旦不对就会**重新分配新槽**,
#   旧槽永不回收 —— 两个人占 18 格就是这么来的(槽位泄漏)。
#   现在开新会话前先按 UUID 把整张表扫一遍: 找到就复用, 找不到才分配。
# 【怎么跑】#i 从 **1** 开始(slot/alloc 分配的槽位是 1..#max_slots, 没有 0 号),
#   命中(#found=1)或超过 #max_slots 就停。
# 【★ F03 修(2026-10-10)】原来 #i 从 0 起、`#i >= #max_slots` 就退 —— 只扫了 0..63,
#   而槽位是 1..#max_slots(默认最大 64) ⇒ **默认第 64 槽永远查不到** ⇒ 那个玩家每次
#   上线都被判"槽位不属于我"→ 被重新分配, 旧索引(#64)残留、还会加速触发溢出。
#   现在起点 1、上界改成 `>`(即扫到并含 #max_slots)。
# ============================================================
execute if score #found manacore.meta matches 1 run return 0
execute if score #i manacore.meta > #max_slots manacore.meta run return 0
data modify storage manacore:work f.uuid set from storage manacore:macro a.uuid
execute store result storage manacore:work f.i int 1 run scoreboard players get #i manacore.meta
function manacore:internal/index/find_uuid with storage manacore:work f
scoreboard players add #i manacore.meta 1
function manacore:internal/index/find_uuid_loop