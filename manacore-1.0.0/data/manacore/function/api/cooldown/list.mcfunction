# ============================================================
# api/cooldown/list —— 导出该玩家全部冷却记录
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/cooldown/list
# 【出参】out.cooldowns = { "<技能id>": {end,total,start}, ... }
# 【用途】调试面板、存档导出。注意里面可能包含已过期的记录(惰性清理)。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/cooldown/list with storage manacore:work a
