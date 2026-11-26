# ============================================================
# fallendream:equipment/axe/angel_core/dmg1 —— 第一段: 基础攻击力 ×8, 重复 2 次
# ------------------------------------------------------------
# 【执行者】施法者   【目标】自身 8 格内带「圣痕」的生物
# 【通道】attack_mul(基数 = 面板 base_attack)
# ============================================================

tag @e[tag=zx.ac_h8] remove zx.ac_h8
execute at @s run tag @e[type=!#fallendream:no_damage,distance=0.1..8,tag=zx.status.shenghen] add zx.ac_h8
execute unless entity @e[tag=zx.ac_h8] run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.ac_h8]",read:"manacore"}
# dup-ok: 文案"重复 2 次", 这里刻意打两遍
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill

# ④.5 【超限（2026-11-22）】有额外「圣痕」的: 被该武器技能锁定时重复次数 +1
#   只补打多出来的那一次 —— "重复 2 次"对所有人都成立，带额外层的实际吃 3 次。
#   ★ 用 zx.sh_x 判（0/1），额外层没有专用标签。
tag @e[tag=zx.ac_h8x] remove zx.ac_h8x
execute as @e[tag=zx.ac_h8] if score @s zx.sh_x matches 1.. run tag @s add zx.ac_h8x
execute if entity @e[tag=zx.ac_h8x,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.ac_h8x]",read:"manacore"}
data modify storage zx:in arg.uncapped set value 1b
execute if entity @e[tag=zx.ac_h8x,limit=1] at @s run function fallendream:internal/attack/api_skill

execute at @e[tag=zx.ac_h8] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.4 0.4 0.05 12 normal
tag @e[tag=zx.ac_h8x] remove zx.ac_h8x
tag @e[tag=zx.ac_h8] remove zx.ac_h8
