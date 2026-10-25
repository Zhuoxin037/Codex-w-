# ============================================================
# sweetdream:equipment/axe/skyvault/ol_aoe —— 超限·天穹连锁段的冲击伤害(宏层)
# ------------------------------------------------------------
# 【宏参数】zx:work sv {tag}   【执行者】施法者
# 【和 aoe 的差别】走的是 **other_mul**(基数 = 施法者**当前**魔力), 不是 max_mana_mul。
#   文案: "落地后对半径 5 格内的生物造成一次相当于自身**当前魔力值** ×0.1 的伤害"。
# 【★ 一定要 with storage zx:work sv 调用 ★】传 zx:data self 会让宏函数一条都不跑(静默)。
# ============================================================

$execute if entity $(tag) run data modify storage manacore:in arg set value {uuid:"",other_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
$execute if entity $(tag) run function manacore:api/damage/calc
$execute if entity $(tag) run data modify storage zx:in arg set value {target:"$(tag)",read:"manacore"}
$execute if entity $(tag) run function sweetdream:api/damage
