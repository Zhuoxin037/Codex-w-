scoreboard players set @s zx.j_host_t -1
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",id:"job_indwell"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/remove

data modify storage zx:work jt.uuid set from storage zx:data self.uuid
function sweetdream:profession/twin/host_finish with storage zx:work jt
