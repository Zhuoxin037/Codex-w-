# ============================================================
# fallendream:equipment/armor/beach_vein/passive —— 滩纹: 护甲 / 低魔回魔
# ------------------------------------------------------------
# 【执行者】每个玩家（second 用 `as @a` 送进来）
# 【文案】魔力上限 +40。自身 5 格内有附有「渊海」的生物时护甲值 +2；
#   若魔力低于 50%，每秒额外恢复 4 魔力。
#   超限: 上限 +160；护甲 +4 且额外 +10%；低魔每秒回 10 魔力 + 护甲韧性 +1；
#     消耗「渊海」后保留护甲 6 秒（保留窗口内也不掉）。
# 【★ 两段互相独立 ★】护甲那段拆进 armor_sync（它内部会 return，不吞回魔段）。
# 【"魔力值上限 +40/+160" 不在这里做】那是 armor_mana/passive 的统一差值账本。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ---- ⓪ 没穿滩纹就没这事（护腿） ----
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] run return 0

# ---- ① 护甲值 +2/+4（差值制，内部可能 return） ----
function fallendream:equipment/armor/beach_vein/armor_sync

# ---- ② 判定档位与低魔状态（不用 return，让 ③ 韧性撤除照常执行） ----
scoreboard players set #bv_ol zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"],ol:"beach_vein"}] run scoreboard players set #bv_ol zx.meta 1

data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #bv_cm zx.meta 0
execute store result score #bv_cm zx.meta run data get storage manacore:out r.value 1000
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #bv_mm zx.meta 0
execute store result score #bv_mm zx.meta run data get storage manacore:out r.value 1000

scoreboard players set #bv_low zx.meta 0
scoreboard players set #bv_half zx.meta 0
scoreboard players operation #bv_half zx.meta = #bv_mm zx.meta
scoreboard players operation #bv_half zx.meta /= #2 zx.meta
execute if score #bv_mm zx.meta matches 1.. if score #bv_cm zx.meta < #bv_half zx.meta run scoreboard players set #bv_low zx.meta 1

# ---- ③ 护甲韧性 +1（超限 + 低魔才挂；否则撤）——★ 必须在任何 return 之前 ★ ----
scoreboard players add @s zx.bv_tou 0
execute if score @s zx.bv_tou matches 1 unless score #bv_low zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier remove fallendream:bv_tou
execute if score @s zx.bv_tou matches 1 unless score #bv_low zx.meta matches 1 run scoreboard players set @s zx.bv_tou 0
execute if score @s zx.bv_tou matches 0 if score #bv_ol zx.meta matches 1 if score #bv_low zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add fallendream:bv_tou 1 add_value
execute if score @s zx.bv_tou matches 0 if score #bv_ol zx.meta matches 1 if score #bv_low zx.meta matches 1 run scoreboard players set @s zx.bv_tou 1

# ---- ④ 低魔回魔：基础 4 / 超限 10 ----
execute unless score #bv_low zx.meta matches 1 run return 0
execute if score #bv_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",value:4.0}
execute if score #bv_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
