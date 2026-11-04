# ============================================================
# sweetdream:equipment/staff/surge_ebb/form4 —— 潮涌，潮枯：登记一个 4 秒的术阵
# ------------------------------------------------------------
# 【执行者】歌者本人    【固定 id】sweetdream:surge_ebb（同 余响/form5 的理由）
# ============================================================

data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:surge_ebb",type:"singer",duration_seconds:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
execute unless data storage manacore:out r{success:1b} run return 0
execute at @s run particle minecraft:bubble ~ ~1 ~ 0.8 0.4 0.8 0.02 10 normal
