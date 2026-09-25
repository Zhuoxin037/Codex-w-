# ============================================================
# api/stats/export —— 导出某个玩家的全部属性
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>"}
#   function manacore:api/stats/export
#   结果: /data get storage manacore:out r.stats
# 【出参】out.stats(整份属性表副本)
# 【注意】是副本, 改它不影响玩家本体。
# ============================================================
# 出参: manacore:out.stats / manacore:out.uuid
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/export with storage manacore:work a
