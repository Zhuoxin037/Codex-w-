# ------------------------------------------------------------
# internal/formation/create_full —— 创建失败(术阵数已达上限 / 无空槽)
# 【宏参数】manacore:work.a {uuid,id,type}
# 【返回】out.success = 0b, out.reason = "formation_limit"
# 【调用方应该做什么】直接跳过后续技能流程, 并给玩家提示"术阵数量已达上限"。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "formation_limit"
