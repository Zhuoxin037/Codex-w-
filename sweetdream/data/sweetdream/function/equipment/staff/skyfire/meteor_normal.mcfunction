# 普通火球: 落点 2 格内的生物, 造成相当于自身基础攻击力 x1 的伤害。
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:0.0,read:"manacore",uncapped:1b}
function sweetdream:api/damage
particle minecraft:flame ~ ~0.5 ~ 0.6 0.4 0.6 0.02 20 normal
playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.6 1.0
