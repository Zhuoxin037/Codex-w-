# ============================================================
# api/cooldown/reduction_get —— 读取冷却缩减
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/cooldown/reduction_get
# 【出参】out.value(0..1 的比例)
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"cooldown_reduction"}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/get with storage manacore:work a
