$execute unless entity $(vx_uuid) run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ---- 空位数 ----
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
scoreboard players set #es_c zx.meta 0
execute store result score #es_c zx.meta run data get storage manacore:out r.count
scoreboard players set #es_lim zx.meta 0
execute store result score #es_lim zx.meta run data get storage manacore:out r.limit
scoreboard players operation #es_e zx.meta = #es_lim zx.meta
scoreboard players operation #es_e zx.meta -= #es_c zx.meta
execute if score #es_e zx.meta matches ..0 run return 0

# 伤害 = 4 × 空位（×2 两次）
scoreboard players set #es_d zx.meta 0
scoreboard players operation #es_d zx.meta = #es_e zx.meta
scoreboard players operation #es_d zx.meta *= #4 zx.meta

$data modify storage zx:work a set value {fixed:1b,target:"$(vx_uuid)",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #es_d zx.meta
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function fallendream:internal/attack/submit_extra

$execute at $(vx_uuid) run particle minecraft:enchant ~ ~1 ~ 0.3 0.4 0.3 0.3 8 normal
$tag $(vx_uuid) remove zx.victim
