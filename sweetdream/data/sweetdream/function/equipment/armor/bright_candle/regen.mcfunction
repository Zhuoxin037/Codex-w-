# ============================================================
# sweetdream:equipment/armor/bright_candle/regen —— 站在「烛火」5 格内每秒回蓝
# ------------------------------------------------------------
# 【执行者】玩家(由 candle_tick ⑦ 送进来)
# 【文案】自身在「烛火」5 格内时每秒额外恢复相当于自身最大魔力值 0.5% 的魔力值。
# 【★ 为什么走 api/mana/add 而不是改回魔速率 ★】装备给的回魔要能突破"禁止自动
#   回魔"(静脉泵 regen_mana 同一条理由)。
# 【×1000 定点】最大魔力 ×1000 ÷ 200 = ×0.005 ×1000, 再 `double 0.001` 还原。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #bc_r zx.meta 0
execute if data storage manacore:out r.value store result score #bc_r zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #bc_r zx.meta /= #200 zx.meta
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bc_r zx.meta
function manacore:api/mana/add

# 记进"装备额外回魔"账本(debug/stats 那一行读它; 它记的是整数点, 所以再 ÷1000)
scoreboard players set #bc_p zx.meta 0
scoreboard players operation #bc_p zx.meta = #bc_r zx.meta
scoreboard players operation #bc_p zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.regen_milli += #bc_r zx.meta
