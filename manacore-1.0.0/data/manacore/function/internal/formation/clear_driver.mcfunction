# ------------------------------------------------------------
# internal/formation/clear_driver —— 展开式清空 8 个槽位
# 【宏参数】manacore:work.entry {uuid}
# ------------------------------------------------------------
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/clear_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/clear_one with storage manacore:work entry
