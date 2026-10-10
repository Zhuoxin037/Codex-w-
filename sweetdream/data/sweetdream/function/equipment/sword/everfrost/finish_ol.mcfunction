# ============================================================
# sweetdream:equipment/sword/everfrost/finish_ol —— 超限·永霜的**整批**收尾
# ------------------------------------------------------------
# 【原文】"…并在结束后对被冰冻的生物造成相当于自身当前魔力值 ×0.15 的伤害。"
# 【执行者】玩家   【入参】storage zx:work ef.uuid
# 【什么时候用它】**打满 10 拍 / 到 10 秒硬上限**时, 把"还挂着标记的全部"一次收尾
#   (pulse_ol ②)。"某一只先解冻"的走 finish_one(**逐只就地收尾**) ——
#   两者分开才能做到不同目标在不同时刻结束(2026-10-08 用户口径)。
# 【和基础版 hit_due 的差别】只有倍率 0.1 -> 0.15, 其余(清标记/删记录/摘 tag)
#   完全照抄 —— 分开写是为了不让基础版那堆 `if` 里再嵌一层 ol 分支。
# ============================================================

# ① 伤害 = 当前魔力 ×0.15(走 other_mul: 基数默认就是当前魔力, 结算那一刻才取)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.15}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打给这批(还是"被冻过的那批", 冰冻早就解了, 标记还在)
$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.ef_$(uuid),distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ③ 表现
$execute at @e[tag=zx.ef_$(uuid),distance=0..] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.6 0.4 0.04 24 normal
$execute at @e[tag=zx.ef_$(uuid),distance=0..] run playsound minecraft:block.glass.break player @a ~ ~ ~ 0.8 0.7

# ④ 收尾: 摘标记 / 删记录 / 摘"等结算"的 tag(和基础版 hit_due 一致)
$tag @e[tag=zx.ef_$(uuid)] remove zx.ef_$(uuid)
$data remove storage zx:data ef."$(uuid)"
tag @s remove zx.ef_casting
