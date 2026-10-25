# ============================================================
# sweetdream:equipment/armor/borrow_fire/set_bonus —— 套装: +100 上限(5 秒) + 回 2%
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】若借火效果是在「烛火」范围内触发的，则护甲和护甲韧性削减额外 -20% ，
#         且自身额外获得 100 魔力值上限并恢复自身 2% 魔力值。
# 【★ "+100 上限"持续多久 ★】文案没写, 这里按**与削减同一个 5 秒窗口**处理
#   (到点由 unstrip_self 退还)。★ 口径待用户确认。
# 【★ 为什么不叠加 ★】5 秒内连续触发两次的话, 上限会变成 +200 而两次到期时间
#   不同步 ⇒ 用账本 zx.bf_mana 判"已经在生效就只续时间"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 立即回 2% 最大魔力(每次触发都回)
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #bf_m zx.meta 0
execute if data storage manacore:out r.value store result score #bf_m zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #bf_m zx.meta /= #50 zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bf_m zx.meta
function manacore:api/mana/add

# ② +100 上限(只在"还没生效"时加)
execute if score @s zx.bf_mana matches 1.. run return 0
scoreboard players add @s zx.bf_mana 100
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
