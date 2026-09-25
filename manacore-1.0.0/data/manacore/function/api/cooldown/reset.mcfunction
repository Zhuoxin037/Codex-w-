# ============================================================
# api/cooldown/reset —— 重置单个技能的冷却
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball"}
#          function manacore:api/cooldown/reset
# 【效果】该技能立刻可用。
# 【用途】技能冷却重置道具、大招刷新。
# ============================================================
data modify storage manacore:work a set value {uuid:"",skill:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/reset with storage manacore:work a
