# ------------------------------------------------------------
# internal/formation/list —— 导出该玩家的术阵列表(含空槽)
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.formations = 8 槽数组副本; 只需要有效项时遍历判断有无 id。
# ------------------------------------------------------------
data modify storage manacore:out r.formations set value []
$execute if data storage manacore:players "$(uuid)".formations run data modify storage manacore:out r.formations set from storage manacore:players "$(uuid)".formations
