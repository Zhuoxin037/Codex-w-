# ============================================================
# api/cooldown/get —— 读取剩余冷却
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball"}
#          function manacore:api/cooldown/get
# 【出参】out.remaining(剩余 tick, 就绪时为 0) / out.ready
# 【用途】UI 倒计时: 剩余 tick / 20 = 剩余秒数。
# ============================================================
data modify storage manacore:work a set value {uuid:"",skill:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/check with storage manacore:work a
