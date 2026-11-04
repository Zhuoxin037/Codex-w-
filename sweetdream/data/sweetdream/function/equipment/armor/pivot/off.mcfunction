# ============================================================
# sweetdream:equipment/armor/pivot/off —— 摘下「枢」时把术阵位上限还回去
# ------------------------------------------------------------
# 【执行者】玩家（pivot/second 在判定"没穿"时调用）
# 【★ 必须先判账本 ★】没加过就减，会把上限变成 2（甚至负数）—— 而且不会报错。
# ============================================================

execute unless score @s zx.pv_lim matches 1 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"formation_limit",value:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.pv_lim 0
