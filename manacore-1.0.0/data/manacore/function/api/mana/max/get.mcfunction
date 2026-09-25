# ============================================================
# api/mana/max/get —— 读取最大魔力
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/mana/max/get
# 【出参】out.value
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"max_mana"}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/get with storage manacore:work a
