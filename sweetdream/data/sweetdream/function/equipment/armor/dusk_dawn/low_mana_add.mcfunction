# ------------------------------------------------------------
# 真的低于一半才走到这里: 回 20 点(走 api/mana/add, 不会超上限)
# ------------------------------------------------------------
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
