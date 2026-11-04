# ============================================================
# sweetdream:equipment/sword/aftersound/passive —— 余响：术阵为空就补一个
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 为什么直接问前置包、不读 zx.fm_u ★】
#   lib/fm/read 的读数**每秒**刷一次。若用秒级读数，同一秒内"被动刚召唤了一个阵"
#   之后的下一次平A仍然读到 0 ⇒ 会连着召唤好几个，直接撞满 3 个上限。
#   api/formation/count 只读玩家记录里的 8 个槽位，不碰玩家 NBT，逐次调用可以接受。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count

scoreboard players set #as_u zx.meta 0
execute store result score #as_u zx.meta run data get storage manacore:out r.count
execute if score #as_u zx.meta matches 1.. run return 0

function sweetdream:equipment/sword/aftersound/form5
