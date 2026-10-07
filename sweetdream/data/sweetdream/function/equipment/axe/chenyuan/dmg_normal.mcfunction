# ============================================================
# sweetdream:equipment/axe/chenyuan/dmg_normal —— 无增益: 当前魔力 ×0.08
# ------------------------------------------------------------
# 【执行者】施法者   【目标】zx.cy_hit
# 【通道】other_mul(基数默认 = 面板当前魔力)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",other_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.cy_hit]",read:"manacore"}
function sweetdream:api/damage
