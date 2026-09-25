# ============================================================
# api/stats/mul —— 属性乘法(数值型)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", key:"max_mana", value:1.25}
#   function manacore:api/stats/mul
# 【语义】新值 = 旧值 x value, 例如 1.25 即"提高 25%"。
# 【用途】百分比类增益/减益。
# 【注意】乘法会累积(每次都在当前值上乘)。需要"基于基准值重算"时,
#   请自行保存基准值并用 stats/set 写回。
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"",value:1.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
function manacore:internal/stats/mul with storage manacore:work a
