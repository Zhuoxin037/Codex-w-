# ============================================================
# sweetdream:equipment/armor/brain_leech/regen_remove —— 摘掉恢复修正
# ------------------------------------------------------------
# 【只在账本记着"挂上了"时才调】按 id 移除一个不存在的修正虽然只是空跑,
#   但配合账本可以少一次遍历 8 个槽位。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:eqp_brain_leech"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/regen/modifier/remove

scoreboard players set @s zx.bl_regen 0
