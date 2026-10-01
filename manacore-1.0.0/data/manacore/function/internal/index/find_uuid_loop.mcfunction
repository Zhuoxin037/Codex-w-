# ============================================================
# manacore:internal/index/find_uuid_loop —— 从 0 号槽开始逐格找"这是谁的槽"
# ------------------------------------------------------------
# 【为什么要它】以前认人只看"玩家自己计分项上的槽号", 那个分数一旦不对就会**重新分配新槽**,
#   旧槽永不回收 —— 两个人占 18 格就是这么来的(槽位泄漏)。
#   现在开新会话前先按 UUID 把整张表扫一遍: 找到就复用, 找不到才分配。
# 【怎么跑】#i 从 0 开始, 命中(#found=1)或超过 #max_slots 就停。
# ============================================================
execute if score #found manacore.meta matches 1 run return 0
execute if score #i manacore.meta >= #max_slots manacore.meta run return 0
data modify storage manacore:work f.uuid set from storage manacore:macro a.uuid
execute store result storage manacore:work f.i int 1 run scoreboard players get #i manacore.meta
function manacore:internal/index/find_uuid with storage manacore:work f
scoreboard players add #i manacore.meta 1
function manacore:internal/index/find_uuid_loop