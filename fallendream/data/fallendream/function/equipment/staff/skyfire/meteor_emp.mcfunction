# 强化火球: 落点 3 格内的生物, 造成 自身最大魔力值 x0.1 伤害, 之后附加「流火」。
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=..3]",damage:0.0,read:"manacore",uncapped:1b}
function fallendream:internal/attack/api_skill
data modify storage zx:work ic set value {target:"@e[type=!#fallendream:no_damage,distance=..3]",mark:"liuhuo"}
function fallendream:tag/mark with storage zx:work ic
particle minecraft:flame ~ ~0.5 ~ 0.9 0.5 0.9 0.03 30 normal
playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.8 0.8
