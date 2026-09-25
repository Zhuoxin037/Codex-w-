# ============================================================
# api/cooldown/reduce —— 减少剩余冷却
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball", ticks:20}
#          function manacore:api/cooldown/reduce
#   (用 seconds 也行, 会自动 x20)
# 【效果】把结束时刻往前推, 相当于"技能冷却减少"。
# 【注意】只对正在冷却的技能生效; 减到 0 以下会在下次 check 时判定为就绪。
# ============================================================
data modify storage manacore:work a set value {uuid:"",skill:"",ticks:0,seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/reduce with storage manacore:work a
