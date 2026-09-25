# ============================================================
# api/formation/list —— 导出某玩家的术阵列表
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/formation/list
# 【出参】out.formations = 8 个槽位的数组(空槽是 {})
# 【遍历建议】自己遍历时用 /execute if data ... formations[i].id 判断该槽位
#   是否真的有术阵, 不要用"元素是否存在"判断(空槽也是元素)。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/formation/list with storage manacore:work a
