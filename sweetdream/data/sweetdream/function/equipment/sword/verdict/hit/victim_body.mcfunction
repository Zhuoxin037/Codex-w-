$execute unless entity $(vx_uuid) run return 0

# 伤害: 基础攻击力 ×2, 对"被击者 2 格内的全部生物"
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
data modify storage zx:in arg.s2_b_damage set value {n:0,d:1}
data modify storage zx:in arg.s2_b_damage set from storage manacore:out r.s2_b_damage
$execute at $(vx_uuid) run function sweetdream:api/damage

# 效果: 虚弱Ⅱ / 缓慢Ⅱ / 发光, 8 秒(施加给"受到伤害的生物")
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:weakness",duration:8,amplifier:1}
$execute at $(vx_uuid) run function sweetdream:api/effect
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:slowness",duration:8,amplifier:1}
$execute at $(vx_uuid) run function sweetdream:api/effect
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:glowing",duration:8,amplifier:0}
$execute at $(vx_uuid) run function sweetdream:api/effect

# 表现
$execute at $(vx_uuid) run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 20 normal
$execute at $(vx_uuid) run playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.5 1.5

# 清理 victim
$tag $(vx_uuid) remove zx.victim
