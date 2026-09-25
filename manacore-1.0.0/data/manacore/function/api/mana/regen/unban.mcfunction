# ============================================================
# api/mana/regen/unban —— 解除禁止恢复
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/mana/regen/unban
# 【效果】永久标记与限时时间戳一起清除。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/mana/unban with storage manacore:work a
