# ------------------------------------------------------------
# internal/formation/slot_driver —— 查找第一个空术阵槽位
# 【宏参数】manacore:work.entry {uuid}
# 【结果】#free = 0..7(空位下标) 或 -1(已满)
# 【算法】按 0..7 顺序扫描, 只记录遇到的第一个空位, 因此不会产生空洞。
# 【为什么"满"是 -1 而不是 8】-1 便于用 matches -1 / matches 0.. 做分派。
# ------------------------------------------------------------
scoreboard players set #free manacore.math -1
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/slot_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/slot_one with storage manacore:work entry
