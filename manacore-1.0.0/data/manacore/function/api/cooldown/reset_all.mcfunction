# ============================================================
# api/cooldown/reset_all —— 清空该玩家的全部冷却
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/cooldown/reset_all
# 【用途】复活、进入新副本、GM 重置。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/cooldown/reset_all with storage manacore:work a
