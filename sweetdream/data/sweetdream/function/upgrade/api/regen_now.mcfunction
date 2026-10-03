# ============================================================
# sweetdream:upgrade/api/regen_now —— 发这一秒的额外回魔
# ------------------------------------------------------------
# 【入参】#up_r = 这一秒该回几点   【执行者】玩家(且 zx:data self.uuid 已备好)
# 【为什么用 mana/add 而不是改"每秒恢复速率"】和静脉泵一个理由:
#   要的是"到点给几点", 一次性加最直接, 也不用管脱下时的清理;
#   而且这条路径不受"禁止魔力恢复"影响(主动回复), 被 ban 了照样生效。
# 【为什么要记 zx.regen_extra】前置包的 regen 接口不认识这种直接 add 的回魔,
#   debug/stats 里那一行"装备额外"就是靠这本账报数的。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #up_r zx.meta
function manacore:api/mana/add

scoreboard players operation @s zx.regen_extra += #up_r zx.meta
