# ============================================================
# sweetdream:equipment/bow/lucid_dream/find_shooter_go —— 读射手当前魔力(执行者 = 射手本人)
# ------------------------------------------------------------
# 【谁调它】find_shooter 反查到的那名玩家
# 【产出】#ld_mana zx.meta = 当前魔力值(整数, 面板原量纲)
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #ld_mana zx.meta run data get storage manacore:out r.value
