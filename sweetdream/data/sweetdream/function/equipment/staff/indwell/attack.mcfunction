execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
function sweetdream:equipment/staff/gate
execute unless score #st_gate zx.meta matches 1 run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:indwell_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",other_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work ball set value {dmg:0.0,style:"indwell",hit:"sweetdream:profession/ball_hit/indwell"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
