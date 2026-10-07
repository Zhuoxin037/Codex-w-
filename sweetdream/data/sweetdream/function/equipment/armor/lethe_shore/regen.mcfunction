# ============================================================
# sweetdream:equipment/armor/lethe_shore/regen —— 残念的每秒回魔
# ------------------------------------------------------------
# 【执行者】玩家   【谁调用它】passive(处于残念时才调)
# 【回多少】#lt_regen 里是每秒回复量(由 passive 填 20)
# 【为什么用 api/mana/add 而不是 regen 速率】照炉心 furnace_core/regen 的取舍:
#   这是"到点直接加一笔", 直接 add 才精确等于 20, 也不会被回魔倍率放大。
#   加超上限由 api/mana/add 内部夹紧。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #lt_regen zx.meta
function manacore:api/mana/add
