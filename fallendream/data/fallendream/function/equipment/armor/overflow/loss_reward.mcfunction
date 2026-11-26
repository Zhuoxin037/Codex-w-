# ============================================================
# fallendream:equipment/armor/overflow/loss_reward —— 超限·溢流：临时生命减少 → 回 1% 上限魔力
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 读面板而不是写死数 ★】1% 跟着最大魔力走（升级/别的装备随时改），
#   与 empty_camp/ol_regen 同口径；结果是 double，不走计分项、不触发 R05。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run data get storage manacore:out r.value 10
function manacore:api/mana/add
