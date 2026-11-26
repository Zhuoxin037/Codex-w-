data modify storage manacore:in arg set value {uuid:"",other_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
