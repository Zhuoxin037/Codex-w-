# ------------------------------------------------------------
# internal/formation/create_go —— 通过上限检查, 找一个空槽位
# 【宏参数】manacore:work.a {uuid,id,type}
# 【流程】slot_driver 找第一个空槽 -> #free
#         #free = -1 -> create_full(理论上不会发生, 属于兜底)
#         #free >= 0 -> create_prep(算时长、写入)
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0}
function manacore:internal/formation/slot_driver with storage manacore:work entry
execute if score #free manacore.math matches -1 run function manacore:internal/formation/create_full with storage manacore:work a
execute if score #free manacore.math matches 0.. run function manacore:internal/formation/create_prep
