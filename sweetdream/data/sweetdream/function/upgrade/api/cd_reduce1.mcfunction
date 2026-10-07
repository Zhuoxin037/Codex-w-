# ============================================================
# sweetdream:upgrade/api/cd_reduce1 —— 把"本武器的技能"剩余冷却 -1 秒
# ------------------------------------------------------------
# 【入参】zx:work cq {uuid, skill}
# 【调用方】upgrade/api/cd_tick 的 ②(冷却剂·Ω)与 ③(魔力沸涌)。
# 【为什么走公开接口】manacore:api/cooldown/reduce 内部对"这个技能没在冷却"
#   有守卫(读不到 .end 就什么都不做), 所以这里不需要先查在不在冷却 ——
#   减一个没在冷却的技能是**空操作**, 不报错、不留脏数据。
# 【减到 0 以下】不会立刻清记录, 下一次 check 判定就绪时顺手删掉(框架的惰性清理)。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0,seconds:1.0}
data modify storage manacore:in arg.uuid set from storage zx:work cq.uuid
data modify storage manacore:in arg.skill set from storage zx:work cq.skill
function manacore:api/cooldown/reduce
