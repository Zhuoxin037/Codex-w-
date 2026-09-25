# ------------------------------------------------------------
# internal/cooldown/check_busy —— 冷却中
# 【宏参数】manacore:work.a {uuid,skill}
# 【出参】out.ready = 0b, out.remaining = 剩余 tick
# 【用途】技能流程据此拒绝释放; UI 可以据此显示倒计时/灰色图标。
# ------------------------------------------------------------
data modify storage manacore:out r.ready set value 0b
execute store result storage manacore:out r.remaining int 1 run scoreboard players get #rem manacore.math
