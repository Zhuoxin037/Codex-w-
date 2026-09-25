# ============================================================
# api/formation/count —— 统计某玩家的术阵数量
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/formation/count
# 【出参】out.count(当前数量) / out.limit(该玩家的上限)
# 【用途】UI 显示"术阵 2/3"、技能判断"还能不能召唤"。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/formation/count with storage manacore:work a
