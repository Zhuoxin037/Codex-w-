# ============================================================
# api/cooldown/increase —— 增加剩余冷却
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball", seconds:3.0}
#          function manacore:api/cooldown/increase
# 【效果】把结束时刻往后推, 相当于"技能冷却增加"(控制/惩罚效果)。
# 【注意】只对正在冷却的技能生效; 想让没在冷却的技能直接进冷却请用 start。
# ============================================================
data modify storage manacore:work a set value {uuid:"",skill:"",ticks:0,seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/increase with storage manacore:work a
