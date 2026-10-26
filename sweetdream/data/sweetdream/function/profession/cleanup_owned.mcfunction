function sweetdream:lib/uuid
data modify storage zx:work jclean.uuid set from storage zx:data self.uuid
execute store result storage zx:work jclean.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jclean.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jclean.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jclean.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:profession/cleanup_owned_go with storage zx:work jclean
data modify storage manacore:in arg set value {uuid:"",id:"job_mana_crystal"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/remove
data modify storage manacore:in arg set value {uuid:"",id:"job_illusion"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/remove
data modify storage manacore:in arg set value {uuid:"",id:"job_indwell"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/remove
