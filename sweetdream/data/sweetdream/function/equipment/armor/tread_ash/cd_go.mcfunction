# ============================================================
# sweetdream:equipment/armor/tread_ash/cd_go —— 把"本次位移技能"的冷却减 4 秒
# ------------------------------------------------------------
# 【宏参数】zx:step cur {skill,uuid,x,y,z}= step_observe 在 cooldown_start 记下的那份
# 【为什么是宏】api/cooldown/reduce 的入参是 {uuid:"<文本>", skill:"<id>", ticks:N}
#   —— uuid 与 skill 都是字符串，只能靠宏变量拼进命令。
# 【★ 只减 80 刻（4 秒）★】文案写死「冷却时间 -4 秒」，不是百分比。
# 【★ 技能已经结束冷却也不报错 ★】internal/cooldown/reduce_body 找不到记录时
#   什么都不做（下一次 check 照常判就绪），所以不需要在这里预判。
# ============================================================

$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"$(skill)",ticks:80}
function manacore:api/cooldown/reduce
