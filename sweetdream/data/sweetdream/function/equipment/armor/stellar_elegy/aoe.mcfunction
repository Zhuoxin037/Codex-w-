# ============================================================
# sweetdream:equipment/armor/stellar_elegy/aoe —— 让"带通用标签"的怪吃一次伤害
# ------------------------------------------------------------
# 【执行者】施法者(被打的玩家)   【目标】zx.marked 标签(lib/marks_any 已经挑好)
# 【数值】自身当前魔力值 ×0.02 —— 当前魔力口径, 所以**不**接 lib/max_mana_bonus
#   (那个是给"最大魔力口径"的技能用的)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.02,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.marked]",read:"manacore"}
function sweetdream:api/damage
tag @e[tag=zx.marked] remove zx.marked
