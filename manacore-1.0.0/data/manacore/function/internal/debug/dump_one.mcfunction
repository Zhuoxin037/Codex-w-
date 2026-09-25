# ------------------------------------------------------------
# internal/debug/dump_one —— 遍历模式下的单玩家导出
# 【宏参数】manacore:work.a {uuid,slot}(由 index/visit 传入)
# 【作用】把条目转交 internal/debug/dump 打印。
# ------------------------------------------------------------
data modify storage manacore:work entry set value {uuid:"",i:0,slot:0}
$data modify storage manacore:work entry.uuid set value "$(uuid)"
$data modify storage manacore:work entry.slot set from storage manacore:index "$(slot)".slot
execute if data storage manacore:work entry run function manacore:internal/debug/dump with storage manacore:work entry
