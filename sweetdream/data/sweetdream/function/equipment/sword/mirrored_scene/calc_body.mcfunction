function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:6.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
