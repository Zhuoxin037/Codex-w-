# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_find_go —— 读施法者 max_mana(执行者 = 施法者)
# ------------------------------------------------------------
# 【谁调它】hit_extra_find 反查到的那名玩家
# 【产出】#ld_mm zx.meta = max_mana(整数)
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #ld_mm zx.meta run data get storage manacore:out r.value
