# ============================================================
# sweetdream:equipment/armor/stellar_elegy/regen —— 受击后的"每秒回 10 魔力"
# ------------------------------------------------------------
# 【执行者】zx.se_regen >= 1 的玩家(每秒跑一次)
# 【为什么走 api/mana/add】它是"直接加魔力", 不会超过上限, 也不受"禁止恢复"影响
#   —— 和静脉泵那个"每秒回 3"是同一套写法, 保持手感一致。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 记进"装备额外回魔"账本(见 core/load 的注释)
scoreboard players add @s zx.regen_extra 10

scoreboard players remove @s zx.se_regen 1
