# ------------------------------------------------------------
# internal/formation/remove_all_one —— 全局删除时处理单个玩家
# 【宏参数】manacore:work.a {uuid}
# 【流程】取出 ctrl.arg 当 id, 复用标准 remove_driver 走一遍。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:""}
data modify storage manacore:work entry.id set from storage manacore:ctrl arg
function manacore:internal/formation/remove_driver with storage manacore:work entry
