# ------------------------------------------------------------
# internal/formation/remove_driver —— 展开式按 id 删除
# 【宏参数】manacore:work.entry {uuid,id}
# 【安全性】同一玩家身上的 id 应当唯一, 命中即清空, 不会造成下标错位。
# ------------------------------------------------------------
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/remove_one with storage manacore:work entry
