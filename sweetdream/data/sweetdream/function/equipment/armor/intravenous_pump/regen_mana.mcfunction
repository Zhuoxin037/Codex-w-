# ============================================================
# sweetdream:equipment/armor/intravenous_pump/regen_mana —— 满血时给 3 点魔力
# ------------------------------------------------------------
# 【执行者】玩家(只有"戴着静脉泵 + 满血"时才会被调到)
# 【为什么直接 mana/add 而不是去改"每秒恢复速率"】
#   要的是"到点给 3 点", 一次性加最直接, 也不用管脱下时的清理。
#   而且 api/mana/add 属于主动回复, 不受"禁止魔力恢复"影响 ——
#   被 ban 了自动回魔的人, 装备给的回魔照样生效, 这正是想要的。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 记进"装备额外回魔"账本 —— 前置包的 regen 接口不认识这种直接 add 的回魔,
# debug/stats 里那一行"装备额外"就是靠它报数的(见 core/load 的注释)。
scoreboard players add @s zx.regen_extra 3
