# ------------------------------------------------------------
# internal/formation/remove —— 删除指定玩家的指定术阵
# 【宏参数】manacore:work.a {uuid,id}
# 【被谁用】api/formation/remove 与 api/formation/force_remove
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:"$(id)"}
function manacore:internal/formation/remove_driver with storage manacore:work entry
