# ============================================================
# sweetdream:equipment/staff/thunderrod/skill —— 引雷针: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 150 魔力 / 冷却 35 秒。使用后对自身 8 格内至多 3 个生物各降下
#   一道闪电。
# 【★ 2026-10-13 起: **只降雷**, 不再有"当前魔力 ×0.05"的伤害 ★】
#   与 bolt_atk 同一决定(数值会超模, 用户拍板砍掉), 详见 bolt_atk 头注。
#   所以本函数不再有 calc, 也不再有"先扣魔力后算"那条(坑 152 对本件失效)。
# 【★ 逐目标落雷为什么用 `at` 不用 `as` ★】`at` 只搬位置、执行者始终是玩家,
#   跨武器增益(挂 lib/on_lightning)要按"玩家"的身份读 @s 的分数。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/thunderrod

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 有目标吗? 8 格内至多 3 个(一个都没有就整个不放 —— 不扣蓝、不进冷却)
tag @e[tag=zx.tr_t,distance=0..] remove zx.tr_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=3] add zx.tr_t
execute unless entity @e[tag=zx.tr_t,distance=0..,limit=1] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[tag=zx.tr_t,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 150
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunderrod",mana:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"引雷针冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 150(技能消耗; 本件已无自身伤害, 这儿纯粹是付费)
data modify storage manacore:in arg set value {uuid:"",value:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunderrod",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 逐个目标落一道雷(位置搬到它脚下, 执行者仍是玩家)
execute at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/bolt_skill

# ⑦ 收尾
tag @e[tag=zx.tr_t,distance=0..] remove zx.tr_t
