# ============================================================
# sweetdream:equipment/armor/profile/gain —— 剖面: 自身恢复 50 魔力值
# ------------------------------------------------------------
# 【执行者】玩家（穿剖面的那个人）
# 【文案】"…则自身恢复 50 魔力值…"
# 【为什么走 manacore:api/mana/add】装备给的回魔要能突破"禁止自动回魔"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 记进"装备额外回魔"账本
scoreboard players add @s zx.regen_extra 50
