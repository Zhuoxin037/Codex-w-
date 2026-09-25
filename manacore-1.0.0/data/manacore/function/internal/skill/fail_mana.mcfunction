# ------------------------------------------------------------
# internal/skill/fail_mana —— 魔力不足, 拒绝释放
# 【宏参数】manacore:work.a {uuid,skill}
# 【出参】out.success=0b / out.reason="mana"
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "mana"
