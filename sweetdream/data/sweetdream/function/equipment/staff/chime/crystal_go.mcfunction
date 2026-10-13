# ============================================================
# sweetdream:equipment/staff/chime/crystal_go —— 共鸣水晶: 每 2 秒的伤害结算(宏)
# ------------------------------------------------------------
# 【谁调用它】crystal_set(反查到的释放者; `with storage zx:work chc`)
# 【宏参数】mm = 倍率(原版 0.03 / 超限 0.05; 由 crystal_set 按水晶的 ol 写好)
# 【执行者】释放者玩家; 【位置】水晶处
# 【伤害】释放者最大魔力值 ×mm -> max_mana_mul 通道(calc 基数自动取执行者的
#   最大魔力) -> 经 api/damage 打出。执行者是玩家 -> 自动带归属, 击杀记玩家头上。
# 【目标】crystal_tick 冻好的 zx.ch_t(6 格内随机一只)。
# ============================================================

# ① 拿 uuid(执行者=释放者, uuid 用于 calc 查面板)
function sweetdream:lib/uuid

# ② 算伤害(最大魔力 ×mm)
$data modify storage manacore:in arg set value {uuid:"",max_mana_mul:$(mm)}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.ch_t]",damage:0.0,read:"manacore"}
function sweetdream:api/damage
