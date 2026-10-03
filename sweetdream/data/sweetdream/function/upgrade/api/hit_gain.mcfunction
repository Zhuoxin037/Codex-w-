# ============================================================
# sweetdream:upgrade/api/hit_gain —— 真的把这一笔回魔加给玩家
# ------------------------------------------------------------
# 【入参】#up_gain   【执行者】玩家
# 【为什么不用 regen 通道】攻击回魔是"命中那一刻立刻给", 走 api/mana/add 最直接,
#   而且它属于主动回复, 不受"禁止魔力恢复"影响。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #up_gain zx.meta
function manacore:api/mana/add
