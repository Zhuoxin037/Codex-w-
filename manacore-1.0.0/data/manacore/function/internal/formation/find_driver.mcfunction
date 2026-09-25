# ------------------------------------------------------------
# internal/formation/find_driver —— 在该玩家身上查指定 id 的术阵
# 【宏参数】manacore:work.entry {uuid,id}
# 【结果】找到 -> out.found=1b / out.index / out.formation(整份副本)
# 【被谁用】api/formation/get(查详情)、api/formation/refresh(刷新时长)
# ------------------------------------------------------------
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/find_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/find_one with storage manacore:work entry
