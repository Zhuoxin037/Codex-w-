# ============================================================
# api/mana/regen/modifier/clear —— 清空全部恢复修正
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/mana/regen/modifier/clear
# 【用途】重算装备/职业前先清零, 避免重复叠加(幂等刷新的常用姿势)。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/mana/mod_clear_all with storage manacore:work a
