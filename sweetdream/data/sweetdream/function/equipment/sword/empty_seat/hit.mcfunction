# ============================================================
# sweetdream:equipment/sword/empty_seat/hit —— 虚位（钻剑 · 被动）
# ------------------------------------------------------------
# 【技能原文】"每个空置的术阵位，使自身每次普攻额外造成 4 点固定伤害。"
# 【空位数】manacore:api/formation/count 出参 r.count（已占） / r.limit（上限）。
#   空位 = limit − count。占用数每件布阵装备不同，所以**每次命中现算**，不缓存
#   （缓存就要维护失效时机，而 count 本来就是一个 O(1) 的接口）。
# 【固定伤害】绕开 api/damage/calc：4 × 空位 直接投递。
# 【★ 注意调用顺序 ★】formation/count 会把 manacore:work a 整份重置
#   （前置包接口的第一行），所以必须先取数、再构建 a —— 反了会把伤害参数冲掉。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/empty_seat_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["empty_seat"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["empty_seat"]}] run return 0

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0

function sweetdream:lib/uuid
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

data modify storage zx:work a set value {fixed:1b,target:"@e[tag=zx.victim,distance=..16,limit=1]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #es_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @e[tag=zx.victim,distance=..16,limit=1] run particle minecraft:enchant ~ ~1 ~ 0.3 0.4 0.3 0.3 8 normal
tag @e[tag=zx.victim] remove zx.victim
