# ============================================================
# api/formation/limit/get —— 读取术阵数量上限
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/formation/limit/get
# 【出参】out.value(默认 3)
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"formation_limit"}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/get with storage manacore:work a
