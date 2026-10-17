# ============================================================
# sweetdream:equipment/armor/beach_vein/passive —— 滩纹: 护甲 +2 / 低魔回魔
# ------------------------------------------------------------
# 【执行者】每个玩家（second 用 `as @a` 送进来）
# 【文案(lore 逐字)】自身魔力值上限 +40。自身 5 格内有附有「渊海」的生物时，自身
#   护甲值 +2；若自身当前魔力值低于最大魔力值的 50%，则每秒额外恢复 4 点魔力值。
# 【★ 两段互相独立 ★】护甲那段"没条件就该退成 0"，回魔那段"不满足就什么都不做" ——
#   所以护甲那段拆进 armor_sync（它内部可以随时 return，不会把回魔那段一起吞掉）。
# 【"魔力值上限 +40" 不在这里做】那是 armor_mana 管的（已登记）。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ⓪ 没穿滩纹就没这事（护腿） ----
#   ★ 这一步不只是守门: 它同时省掉下面两次 stats/get —— 本函数被广播给 @a,
#     绝大多数玩家没穿, 早退一次就少两次跨包调用。check.py 的"@a 广播必须自带
#     穿着门控"规则也要求被广播调用的函数体内出现 `items entity @s`。
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] run return 0

# ---- ① 护甲值 +2（差值制，内部可能 return） ----
function sweetdream:equipment/armor/beach_vein/armor_sync

# ---- ② 当前魔力 < 最大魔力 50% -> 每秒额外恢复 4 点魔力值 ----
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #bv_cm zx.meta run data get storage manacore:out r.value 1000
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #bv_mm zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #bv_half zx.meta 0
scoreboard players operation #bv_half zx.meta = #bv_mm zx.meta
scoreboard players operation #bv_half zx.meta /= #2 zx.meta
execute if score #bv_cm zx.meta >= #bv_half zx.meta run return 0
execute if score #bv_mm zx.meta matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",value:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
