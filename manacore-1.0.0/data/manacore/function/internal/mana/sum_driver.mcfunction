# ------------------------------------------------------------
# internal/mana/sum_driver —— 展开式累加 8 个修正槽位
# 【宏参数】manacore:work.entry {uuid}
# 【做法】#sum 清零 -> 逐个把 i 写进 entry.i -> 调用 sum_one -> 累加
# 【和 regen_driver 的区别】这里只统计数值(不判过期、不改数据), 供查询用。
# 【扩展】槽位数与 regen_driver 必须保持一致, 否则两边统计口径会不同。
# ------------------------------------------------------------
scoreboard players set #sum manacore.math 0
data modify storage manacore:work entry.i set value 0
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/mana/sum_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/mana/sum_one with storage manacore:work entry
