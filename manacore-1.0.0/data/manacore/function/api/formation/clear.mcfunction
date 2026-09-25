# ============================================================
# api/formation/clear —— 清空某玩家的全部术阵
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/formation/clear
# 【行为】逐个清槽, 每个都会抛一次 formation_remove(reason="clear")。
# 【用途】① 玩家主动关闭所有术阵 ② 离线清理(框架内部也用它)
# 【注意】不受数量上限影响, 永远能清空。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/formation/clear_all with storage manacore:work a
