function sweetdream:profession/twin/host_end
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:indwell",seconds:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
