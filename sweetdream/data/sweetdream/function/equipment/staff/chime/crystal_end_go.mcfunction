# ============================================================
# sweetdream:equipment/staff/chime/crystal_end_go —— 共鸣水晶·自毁的伤害结算
# ------------------------------------------------------------
# 【谁调用它】crystal_end_set(反查到的释放者)
# 【执行者】释放者玩家   【位置】水晶处(调用链保留; 本文件不依赖坐标)
# 【伤害】释放者**当前魔力** ×0.2 -> other_mul 通道(other_mul 的基数默认 = 当前魔力;
#   见 manacore 的 api/damage/calc 缺省规则 —— 注意这里不是 max_mana_mul)。
# 【目标】crystal_end 圈好的 zx.ch_e(= 自毁时水晶 5 格内的全部生物)。
# 【★ 本文件不许出现 ~ / distance= ★】(同 pass_go: 它跑在"as 释放者"的链上)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid

# ② 算伤害(当前魔力 ×0.2)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.2}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去(5 格内全部)
data modify storage zx:in arg set value {target:"@e[tag=zx.ch_e]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
