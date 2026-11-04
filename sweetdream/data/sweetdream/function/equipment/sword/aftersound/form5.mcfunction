# ============================================================
# sweetdream:equipment/sword/aftersound/form5 —— 余响：登记一个 5 秒的术阵
# ------------------------------------------------------------
# 【执行者】歌者本人（需要 zx:data self.uuid）
# 【固定 id】sweetdream:aftersound —— 本件同一时刻最多 3 个术阵（前置包上限），
#   重复 id 只影响"按 id 删除"，而这里从不主动删（靠时长自然到期），所以安全。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:aftersound",type:"singer",duration_seconds:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
execute unless data storage manacore:out r{success:1b} run return 0
execute at @s run particle minecraft:enchant ~ ~1 ~ 0.8 0.5 0.8 0.02 12 normal
