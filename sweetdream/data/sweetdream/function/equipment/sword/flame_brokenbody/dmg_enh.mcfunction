# 强化第三段：由 combat/ring 在回旋焰刃展开时调用；前两段分别复用 dmg。
# 第二段: 自身 6 格内, ×0.2



data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

tag @e[tag=zx.fb_ring] remove zx.fb_ring
tag @e[type=!#sweetdream:no_damage,distance=..6] add zx.fb_ring
data modify storage zx:in arg set value {target:"@e[tag=zx.fb_ring]",read:"manacore"}
function sweetdream:api/damage
tag @e[tag=zx.fb_ring] remove zx.fb_ring
