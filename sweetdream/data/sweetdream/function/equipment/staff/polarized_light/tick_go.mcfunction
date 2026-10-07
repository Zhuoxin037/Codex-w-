# ============================================================
# sweetdream:equipment/staff/polarized_light/tick_go —— 光束伤害结算
# ------------------------------------------------------------
# 【谁调用它】tick 第 ② 步(确认锁到了目标才调; 执行者 = 施法玩家)
# 【伤害】当前魔力 ×0.05 → other_mul 通道 → calc → 经 api/damage 打出。
#   read:"manacore" = 直接吃 calc 的出参(见 api/damage 头注释)。
#   执行者是玩家 → api/damage 自动带上归属, 击杀记在玩家头上。
# ============================================================

# ① 算伤害(基数 = 当前魔力, 框架自动取)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.05}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.pl_lock]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
