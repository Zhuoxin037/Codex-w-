function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score @s zx.j_at run data get storage manacore:out r.value
