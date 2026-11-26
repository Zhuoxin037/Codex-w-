# ============================================================
# fallendream:equipment/armor/empty_camp/ol_regen —— 超限·空营：无敌对时每秒回 1% 上限魔力
# ------------------------------------------------------------
# 【执行者】玩家  【出参】manacore:in arg.value = 1% 最大魔力
# 【★ 为什么不写死数字 ★】"1%"必须跟着最大魔力走(被动/升级/别的装备随时在改)，
#   读面板 max_mana 再 ×10÷1000；api/mana/add 的 value 是 double，不走计分项。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 0.001 run data get storage manacore:out r.value 10
