# ============================================================
# api/formation/check —— 是否还能再创建一个术阵
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/formation/check
# 【出参】out.can_create(1b/0b) / out.count / out.limit
# 【只读】不修改数据。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.can_create set value 0b
execute if data storage manacore:work a.uuid run function manacore:internal/formation/check with storage manacore:work a
