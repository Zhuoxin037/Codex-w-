# ------------------------------------------------------------
# internal/mana/mod_remove_driver —— 展开式删除 8 个槽位
# 【宏参数】manacore:work.entry {uuid,id}
# 【做法】逐个把 i 写进 entry.i 再调用 mod_remove_one。
# 【注意】同一个 id 只占一个槽位, 所以这里不会出现"删完下标错位"的问题
#         (术阵按 id 删除同理)。
# ------------------------------------------------------------
data modify storage manacore:work entry.i set value 0
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/mana/mod_remove_one with storage manacore:work entry
