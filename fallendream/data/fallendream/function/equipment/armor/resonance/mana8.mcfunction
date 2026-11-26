# fallendream:equipment/armor/resonance/mana8 —— 超限·共振：术阵位全满时每秒回 8 魔力
# 【执行者】玩家   【要求】调用方已取好 lib/uuid
# 【文案】术阵位全满时，自身每秒恢复 8 魔力值。
data modify storage manacore:in arg set value {uuid:"",value:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
