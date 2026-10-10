# ------------------------------------------------------------
# 【超限·影刃】分支 A: 刷新影刃自己的冷却 + 返还 100 魔力
#   (基础版是返 60; 超限版文案写的是 100)
# ------------------------------------------------------------
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:shadow_blade"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reset

data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
