function fallendream:equipment/staff/gate
execute unless score #st_gate zx.meta matches 1 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:firefly_staff_attack",mana:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",other_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work ball set value {dmg:0.0,style:"firefly_staff"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work ball.s2_b_dmg set from storage manacore:out r.s2_b_damage
function fallendream:equipment/staff/attack
data modify storage zx:work firefly set value {uuid:"",ol:0}
data modify storage zx:work firefly.uuid set from storage zx:data self.uuid
# 超限档(决定"萤火上限 12"与萤火自身的碰撞/伤害口径) —— 生成时拍一次, 之后换手不影响
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["firefly_staff"],ol:"firefly_staff"}] run data modify storage zx:work firefly.ol set value 1
function fallendream:equipment/staff/firefly_staff/spawn with storage zx:work firefly
