# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_hurt_go —— 暗海每秒伤害: 结算
# ------------------------------------------------------------
# 【谁调用它】sea_hurt(执行者 = 释放者玩家)
# 【伤害】释放者最大魔力 ×0.06 —— 走 max_mana_mul 通道(calc 的基数自动取
#   执行者的最大魔力) -> api/damage(read:"manacore" = 直接吃 calc 出参)。
#   执行者是玩家 -> api/damage 自动带归属, 击杀记释放者头上。
# 【一次打完一片海里所有目标】@e[tag=zx.sea_hurt_t] 可能是好几只 ——
#   api/damage 的 target 支持范围选择器(它内部逐个 as 处理), 不用自己循环。
# 【目标标签的原子性】zx.sea_hurt_t 由 sea_enter 在 sea_tick ④ 打, 这里用完,
#   下一片暗海开始时清。sea_tick 逐片原子执行, 不会串。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.sea_hurt_t]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
