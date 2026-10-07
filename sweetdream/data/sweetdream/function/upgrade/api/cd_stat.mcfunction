# ============================================================
# sweetdream:upgrade/api/cd_stat —— 把冷却缩减写进前置包的属性
# ------------------------------------------------------------
# 【入参】#cdr = 0..1000(×1000 的缩减比例; 50 = 5%)   【执行者】玩家(zx:data self.uuid 已备好)
# 【为什么要 ×1000 再过一手】cooldown_reduction 是 double(0.05), 而计分板只有整数
#   —— 定点换算, 和 overlimit/api/mod 那一套同源。
# 【为什么记 zx.cdr】调用方每秒都会来, 值没变就没必要重写整份玩家记录。
# 【★ 这条属性是谁的 ★】本系统**独占** manacore 的 cooldown_reduction(全包只有
#   这里写、只有 manacore 的 apply_reduce 读)。以后别的来源也要加冷却缩减时,
#   必须改成"多方求和"而不是直接 set, 否则会互相覆盖。
# ============================================================

data modify storage zx:work cdr.value set value 0.0
execute store result storage zx:work cdr.value double 0.001 run scoreboard players get #cdr zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"cooldown_reduction",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work cdr.value
function manacore:api/cooldown/reduction_set

scoreboard players operation @s zx.cdr = #cdr zx.meta
