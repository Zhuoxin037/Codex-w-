# ============================================================
# sweetdream:equipment/axe/charge/hit_area —— 落点 1 格内的范围伤害
# ------------------------------------------------------------
# 【执行者】施法者; 【位置】被打中的那只生物身上(所以 distance 相对它算)
# 【数值】当前魔力 ×0.05 —— 走"其他倍率"通道(other_mul), 所以吃不到 mm 通道的
#   「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)
# 【为什么先用标签把范围圈起来】范围选择器在宏里会被重算, 先固定成标签更稳,
#   也方便打完之后一次性清理。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",other_mul:0.05,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

tag @e[tag=zx.chg_aoe] remove zx.chg_aoe
tag @e[type=!#sweetdream:no_damage,distance=..1] add zx.chg_aoe
data modify storage zx:in arg set value {target:"@e[tag=zx.chg_aoe]",read:"manacore"}
function sweetdream:api/damage
tag @e[tag=zx.chg_aoe] remove zx.chg_aoe
