# ============================================================
# sweetdream:equipment/axe/angel_core/dmg1 —— 第一段: 基础攻击力 ×8, 重复 2 次
# ------------------------------------------------------------
# 【执行者】施法者   【目标】自身 8 格内带「圣痕」的生物
# 【通道】attack_mul(基数 = 面板 base_attack)
# ============================================================

tag @e[tag=zx.ac_h8] remove zx.ac_h8
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.shenghen] add zx.ac_h8
execute unless entity @e[tag=zx.ac_h8] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.ac_h8]",read:"manacore"}
# dup-ok: 文案"重复 2 次", 这里刻意打两遍
execute at @s run function sweetdream:api/damage
execute at @s run function sweetdream:api/damage

execute at @e[tag=zx.ac_h8] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.4 0.4 0.05 12 normal
tag @e[tag=zx.ac_h8] remove zx.ac_h8
