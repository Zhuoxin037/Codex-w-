# ------------------------------------------------------------
# internal/mana/mod_find_driver —— 查找第一个空修正槽位
# 【宏参数】manacore:work.entry {uuid}
# 【结果】#free = 0..7(空槽位下标) 或 -1(全满)
# 【原理】按 0..7 顺序检查, 只有"该槽位没有 value 字段"且 #free 仍为 -1 时
#         才记录下标, 所以拿到的一定是最小的空位, 不会出现空洞堆积。
# ------------------------------------------------------------
scoreboard players set #free manacore.math -1
data modify storage manacore:work entry.i set value 0
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/mana/mod_find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/mana/mod_find_one with storage manacore:work entry
