# ============================================================
# api/stats/add —— 属性加法(数值型)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", key:"max_health", value:4.0}
#   function manacore:api/stats/add
# 【用途】装备/升级的永久加成: 穿上加正数, 脱下用负数减回去。
# 【前提】目标属性必须已存在, 否则会先自动补 0.0 再相加。
# 【注意】只对数值生效, 不要对 cooldowns / formations 这类复合字段使用。
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
function manacore:internal/stats/add with storage manacore:work a
