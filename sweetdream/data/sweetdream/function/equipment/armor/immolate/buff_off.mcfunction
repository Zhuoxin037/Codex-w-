data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:-100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.im_buff_mk 0