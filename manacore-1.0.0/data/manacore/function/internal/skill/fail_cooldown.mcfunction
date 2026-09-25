# ------------------------------------------------------------
# internal/skill/fail_cooldown —— 冷却未结束, 拒绝释放
# 【宏参数】manacore:work.a {uuid,skill}
# 【出参】out.success=0b / out.reason="cooldown" / out.remaining=剩余 tick
# 【不扣魔力】因为魔力扣除在第 ② 步, 而这里已经中断了流程。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "cooldown"
