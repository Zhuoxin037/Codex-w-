# 天火 普攻: 60 魔力, 固定伤害 1 (custom_damage, 不吃三条倍率通道)
# 命中回调 ball_hit 在命中位置登记延迟火球 marker。
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function fallendream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:skyfire_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",custom_damage:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work ball set value {dmg:0.0,style:"skyfire",hit:"fallendream:equipment/staff/skyfire/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work ball.s2_b_dmg set from storage manacore:out r.s2_b_damage
function fallendream:equipment/staff/attack
