# ============================================================
# api/mana/remove —— 扣除魔力(不判定够不够)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", value:15.0}
#   function manacore:api/mana/remove
# 【规则】不低于 0。
# 【想要"不够就不扣"的语义】请用 api/mana/consume, 它会回传 out.success。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:work a.op set value "remove"
function manacore:api/player/ensure
function manacore:internal/mana/apply with storage manacore:work a
