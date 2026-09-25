# ============================================================
# api/player/reset —— 重置某玩家的全部数据
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>"}
#   function manacore:api/player/reset
# 【效果】属性回到默认值, 术阵/冷却/恢复修正全部清空。
# 【风险】不可撤销。建议先 api/stats/export + debug/dump 留档。
# 【例外】不会动槽位索引; 若索引被清, 他下次上线会自动重新占槽。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/debug/reset_one with storage manacore:work a
