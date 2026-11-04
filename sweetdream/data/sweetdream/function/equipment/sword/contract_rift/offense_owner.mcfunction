function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",attack_mul:3.5}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work cr_delay.num set from storage manacore:out r.damage
data modify storage zx:work cr_delay.s2_b_num set value {n:0,d:1}
data modify storage zx:work cr_delay.s2_b_num set from storage manacore:out r.s2_b_damage
data modify storage zx:work cr_delay.type set value "sweetdream:skill"
data modify storage zx:work cr_delay.uncapped set value 1b
execute at @e[tag=zx.victim,distance=0..,limit=1] run function sweetdream:equipment/sword/contract_rift/delay_new
function sweetdream:equipment/sword/contract_rift/heal_body_find with storage zx:work cr_delay
