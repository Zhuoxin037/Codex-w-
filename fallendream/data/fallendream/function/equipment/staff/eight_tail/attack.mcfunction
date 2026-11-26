function fallendream:equipment/staff/gate
execute unless score #st_gate zx.meta matches 1 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:eight_tail_attack",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
scoreboard players add @s zx.et_fox 0
scoreboard players set #et_enhanced zx.meta 0
execute if score @s zx.et_fox matches 8.. run scoreboard players set #et_enhanced zx.meta 1
scoreboard players add @s zx.et_fox 1
data modify storage manacore:in arg set value {uuid:"",other_mul:0.01}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work ball set value {dmg:0.0,style:"eight_tail"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work ball.s2_b_dmg set from storage manacore:out r.s2_b_damage
execute if score #et_enhanced zx.meta matches 0 run function fallendream:equipment/staff/attack
execute if score #et_enhanced zx.meta matches 1 run function fallendream:equipment/staff/eight_tail/burst
