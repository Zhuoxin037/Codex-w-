# ============================================================
# sweetdream:equipment/armor/borrow_fire/set_unbonus —— 退还套装那 +100 魔力上限
# ------------------------------------------------------------
# 【执行者】玩家   【前置】zx.bf_mana = 当前"已经加上去"的数值(0 = 没生效)
# 【★ 为什么用 `double -1` 而不是去凑一个负数常量 ★】`execute store ... double -1`
#   直接把分数取负写回去, 不用额外注册"负一百"之类的常量假玩家。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
execute if score @s zx.bf_mana matches ..0 run return 0

scoreboard players operation #bf_mm zx.meta = @s zx.bf_mana
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -1 run scoreboard players get #bf_mm zx.meta
function manacore:api/stats/add
scoreboard players set @s zx.bf_mana 0
