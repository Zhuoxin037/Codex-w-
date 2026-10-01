# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/dmg —— 基础一击
# ------------------------------------------------------------
# 【执行者】施法者   【目标】zx.fb_hit 标签(cast 已经圈好: 前方 5*3)
# 【数值】最大魔力 ×0.1 —— 最大魔力口径, 所以吃「下一次技能加成」
#   (统一走 lib/max_mana_bonus: 普通乘区, 用完即删)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
data modify storage zx:work wg.uuid set from storage zx:data self.uuid
function sweetdream:lib/max_mana_bonus with storage zx:work wg
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.fb_hit]",read:"manacore"}
function sweetdream:api/damage
