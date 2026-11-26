function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
$data modify storage manacore:in arg set value {uuid:"",value:$(value)}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
