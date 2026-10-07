# ============================================================
# sweetdream:equipment/armor/stellar_elegy/aoe —— 让"带通用标签"的怪吃一次伤害
# ------------------------------------------------------------
# 【执行者】施法者(被打的玩家)   【目标】zx.marked 标签(lib/marks_any 已经挑好)
# 【数值】自身当前魔力值 ×0.02 —— 走"其他倍率"通道(other_mul, 基数默认当前魔力),
#   所以**不**吃 mm 通道的「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)
# 【★ 超限版: ×0.02 -> ×0.03, 并追加"随机附加一个效果" ★】
#   附加排在伤害之后 —— 文案是"受到一次…伤害**并使其**随机附加一个效果"。
# ============================================================

function sweetdream:equipment/armor/stellar_elegy/is_ol

execute unless score #se_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",other_mul:0.02,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #se_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",other_mul:0.03,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.marked]",read:"manacore"}
function sweetdream:api/damage

# 超限版追加: 给这批生物**各**随机附一个通用效果
execute if score #se_ol zx.meta matches 1 run function sweetdream:equipment/armor/stellar_elegy/rnd_mark

tag @e[tag=zx.marked] remove zx.marked
