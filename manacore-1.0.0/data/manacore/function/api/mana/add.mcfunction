# ============================================================
# api/mana/add —— 回复魔力
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", value:30.0}
#   function manacore:api/mana/add
# 【规则】不超过 max_mana。
# 【区别】这条路径不受"禁止魔力恢复"限制, 属于主动回复(药剂/道具)。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:work a.op set value "add"
function manacore:api/player/ensure
function sweetdream:profession/mana_restore_gate
function manacore:internal/mana/apply with storage manacore:work a
