# ============================================================
# api/mana/set —— 直接设置当前魔力
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", value:50.0}
#   function manacore:api/mana/set
# 【规则】结果自动夹取到 [0, max_mana]。
# 【用途】复活补满、进入副本重置、GM 调整。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:work a.op set value "set"
function manacore:api/player/ensure
function manacore:internal/mana/apply with storage manacore:work a
