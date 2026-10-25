# ============================================================
# sweetdream:equipment/armor/tide_fold/regen —— 自身穿过水墙回蓝（最大魔力 ×1%）
# ------------------------------------------------------------
# 【执行者】玩家(由 cross_player ⑥ 送进来, 已确认是墙的主人)
# 【文案】"每 2 秒穿过时可以恢复自身相当于自身最大魔力值 1% 的魔力值"
# 【×1000 定点】最大魔力 ×1000 ÷ 100 = ×0.01 ×1000, 再 `double 0.001` 还原。
#   ★ 除数是 100 不是 1000: ÷1000 就只剩 0.1% 了(R05 定点口径, 别跟着 ÷1000 走)。
# 【为什么走 api/mana/add】装备给的回魔要能突破"禁止自动回魔"(与明烛 regen 同)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #tf_r zx.meta 0
execute if data storage manacore:out r.value store result score #tf_r zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #tf_r zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #tf_r zx.meta
function manacore:api/mana/add

# 记进"装备额外回魔"账本(整数点)
scoreboard players set #tf_p zx.meta 0
scoreboard players operation #tf_p zx.meta = #tf_r zx.meta
scoreboard players operation #tf_p zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.regen_milli += #tf_r zx.meta
