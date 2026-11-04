# ============================================================
# sweetdream:equipment/staff/surge_ebb/passive —— 潮涌，潮枯：术阵未满就补阵，满了就续追随者
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 直接问前置包的 count ★】lib/fm/read 是秒级读数；同一秒里刚补过一个阵之后
#   再打一下，秒级读数还是旧值 ⇒ 会连补好几个。这里逐次查（只读 8 个槽位，不碰 NBT）。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count

scoreboard players set #se_u zx.meta 0
scoreboard players set #se_c zx.meta 0
execute store result score #se_u zx.meta run data get storage manacore:out r.count
execute store result score #se_c zx.meta run data get storage manacore:out r.limit

execute if score #se_u zx.meta < #se_c zx.meta run function sweetdream:equipment/staff/surge_ebb/form4
execute unless score #se_u zx.meta < #se_c zx.meta run function sweetdream:equipment/staff/surge_ebb/extend
