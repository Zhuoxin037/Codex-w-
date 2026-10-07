# ============================================================
# sweetdream:equipment/bow/rainbow/find_owner_go —— 读施加者 max_health(执行者 = 施加者本人)
# ------------------------------------------------------------
# 【谁调它】find_owner 反查到的那个玩家
# 【产出】#rb_mhp zx.meta = max_health ×100
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #rb_mhp zx.meta run data get storage manacore:out r.value 100
