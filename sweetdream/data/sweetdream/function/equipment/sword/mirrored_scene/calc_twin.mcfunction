function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
