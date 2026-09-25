# ------------------------------------------------------------
# internal/skill/check_nomana —— 只读检查: 魔力不足
# 【注意】这里不扣魔力, 只是把结果标成不可释放。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "mana"
