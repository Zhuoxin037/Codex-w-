# ============================================================
# sweetdream:equipment/armor/withered_garden/wood_go —— 朽木伤害结算
# ------------------------------------------------------------
# 【谁调用它】wood_set(执行者 = 释放者玩家)
# 【伤害】释放者最大魔力 ×0.08 → max_mana_mul 通道(calc 的基数自动取执行者
#   的最大魔力) → 经 api/damage 打出(read:"manacore" = 直接吃 calc 出参)。
#   执行者是玩家 → api/damage 自动带归属, 击杀记玩家头上。
# 【渊海的额外一次】hit2 = 缓慢 ∩ 渊海(wood_tick 已圈好), 同倍率再打一波。
# 【目标标签的原子性】zx.gd_hit / zx.gd_hit2 在 wood_tick 圈好、这里用完;
#   second 逐只朽木原子执行, 不会串。
# ============================================================

# ① 第一波: 5 格内有缓慢效果的
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.gd_hit]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ② 第二波: 其中同时有渊海的, 额外一次(hit2 为空时打空, 无害)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.gd_hit2]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
