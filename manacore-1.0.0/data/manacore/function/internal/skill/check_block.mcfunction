# ------------------------------------------------------------
# internal/skill/check_block —— 只读检查: 冷却未就绪
# 【注意】check 系列完全不改数据, 可以放心在 UI 里高频调用。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "cooldown"
