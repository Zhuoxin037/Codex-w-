# ============================================================
# sweetdream:equipment/sword/deepsea_echo/pay_mana —— 重复一次要花的 110 魔力
# ------------------------------------------------------------
# 【执行者】施法者    【出参】manacore:out r.success (由 wave_go 判)
# 【为什么单独一个文件】consume 要三行, 没法塞进 execute if ... run 里。
# 【扣不动就不扣】api/mana/consume 要么全扣要么一点不扣, 所以不足时
#   不会出现"扣了一半"的情况, 连锁直接在 wave_go 里中断。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:110.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
