# ============================================================
# sweetdream:equipment/armor/heart_vein/regen —— 泵动叠加时自身回 1% 最大魔力
# ------------------------------------------------------------
# 【执行者】玩家（穿心脉、消耗了噬心的那个人）
# 【文案】"…并使自身恢复相当于自身最大魔力值 1% 的魔力值。"
# 【×1000 定点】最大魔力 ×1000 ÷ 100 = ×0.01 ×1000, 再 `double 0.001` 还原。
# 【为什么走 manacore:api/mana/add】装备给的回魔要能突破"禁止自动回魔"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #hv_r zx.meta 0
execute if data storage manacore:out r.value store result score #hv_r zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #hv_r zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #hv_r zx.meta
function manacore:api/mana/add

# 记进"装备额外回魔"账本（整数点）
scoreboard players set #hv_p zx.meta 0
scoreboard players operation #hv_p zx.meta = #hv_r zx.meta
scoreboard players operation #hv_p zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.regen_milli += #hv_r zx.meta
