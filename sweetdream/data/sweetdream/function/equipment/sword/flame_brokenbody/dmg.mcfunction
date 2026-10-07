# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/dmg —— 基础一击
# ------------------------------------------------------------
# 【执行者】施法者   【目标】zx.fb_hit 标签(cast 已经圈好: 前方 5*3)
# 【数值】最大魔力 ×0.1 —— 最大魔力口径, 所以吃「最大魔力值技能倍率」通用加成
#   (风声 / 忘川彼岸 / 无效; 由 lib/mm_add/hook_calc 统一折进 mm 加算池)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.fb_hit]",read:"manacore"}
function sweetdream:api/damage
