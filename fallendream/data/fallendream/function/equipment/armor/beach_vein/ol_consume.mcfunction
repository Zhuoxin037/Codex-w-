# ============================================================
# fallendream:equipment/armor/beach_vein/ol_consume —— 超限·滩纹: 消耗渊海后的 6 秒护甲保留 + 低魔回 3%
# ------------------------------------------------------------
# 【执行者】自身（消耗渊海的玩家；on_consume ⑩ 已判穿超限滩纹 + mark=yuanhai）
# 【文案(逐字)】"自身消耗「渊海」后且范围内没有附有「渊海」的生物时，上述护甲加成
#   继续保留 6 秒。且若此时魔力值低于最大魔力值的50%，则额外恢复一次 3% 魔力值。"
# 【★ 只开保留窗口，不直接加护甲 ★】armor_sync 每秒读 zx.bv_keep > #now 决定 +4；
#   这样"范围内还有渊海"和"窗口保留"两条路统一在一个地方结算，不会重复挂 modifier。
# 【★ 3% 回魔只在"此刻"低魔时给一次 ★】"若此时魔力值低于..." = 消耗这一刻判, 不持续。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ---- ① 开 6 秒保留窗口（绝对刻 = #now + 120） ----
scoreboard players operation @s zx.bv_keep = #now manacore.meta
scoreboard players add @s zx.bv_keep 120

# ---- ② 此刻魔力 <50% -> 回一次 3% 最大魔力 ----
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

scoreboard players set #bv_half zx.meta 0
scoreboard players operation #bv_half zx.meta = #bv_mm zx.meta
scoreboard players operation #bv_half zx.meta /= #2 zx.meta
execute unless score #bv_mm zx.meta matches 1.. run return 0
execute if score #bv_cm zx.meta >= #bv_half zx.meta run return 0

# 3% = ×3÷100，R05 上界保护
scoreboard players set #bv_3 zx.meta 3
scoreboard players set #bv_100 zx.meta 100
scoreboard players set #bv_cap zx.meta 2147483647
scoreboard players operation #bv_cap zx.meta /= #bv_3 zx.meta
scoreboard players operation #bv_add zx.meta = #bv_mm zx.meta
execute if score #bv_add zx.meta > #bv_cap zx.meta run scoreboard players operation #bv_add zx.meta = #bv_cap zx.meta
scoreboard players operation #bv_add zx.meta *= #bv_3 zx.meta
scoreboard players operation #bv_add zx.meta /= #bv_100 zx.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bv_add zx.meta
function manacore:api/mana/add
