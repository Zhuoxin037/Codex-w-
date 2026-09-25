# ------------------------------------------------------------
# internal/formation/count_driver —— 展开式统计 8 个槽位
# 【宏参数】manacore:work.entry {uuid}
# 【结果】#count = 有 id 字段的槽位个数
# 【统一约定】所有 *_driver 都是"设置下标 -> 调 *_one"的展开式循环,
#   这是在没有循环语法的环境下遍历固定长度列表的标准做法。
# ------------------------------------------------------------
scoreboard players set #count manacore.math 0
data modify storage manacore:work entry.i set value 0
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/formation/count_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/formation/count_one with storage manacore:work entry
