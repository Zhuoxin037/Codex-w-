# 宏: 把"手持武器的技能"冷却 -15 秒($(id) = 那件装备的 id)
$data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:$(id)",seconds:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce
