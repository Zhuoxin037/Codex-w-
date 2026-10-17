# ============================================================
# sweetdream:equipment/armor/backlight/cd_go —— 把"这一个技能"的冷却减 8 秒
# ------------------------------------------------------------
# 【宏参数】zx:work bk {uuid,skill,ticks}
# 【为什么是宏】api/cooldown/reduce 的入参是 {uuid:"<文本>", skill:"<id>", ticks:N}
#   —— uuid 与 skill 都是字符串，只能靠宏变量拼进命令。
# 【★ 8 秒 = 160 刻 ★】文案写死「冷却时间 -8 秒」。
# ============================================================

$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"$(skill)",ticks:$(ticks)}
function manacore:api/cooldown/reduce
