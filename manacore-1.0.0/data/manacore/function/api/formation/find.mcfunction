# ============================================================
# api/formation/find —— 全服查找某个 id 术阵的归属
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {id:"mypack:fire_array"}
#          function manacore:api/formation/find
# 【出参】out.found(1b/0b) / out.uuid(归属玩家) / out.index(槽位号) / out.formation
# 【用途】"这个术阵是谁放的?" —— 用于触发对应的连锁反应。
# 【代价】和 force_remove_all 一样是遍历式查询, 别高频调用。
# ============================================================
data modify storage manacore:out r.found set value 0b
data modify storage manacore:ctrl arg set value ""
execute if data storage manacore:in arg.id run data modify storage manacore:ctrl arg set from storage manacore:in arg.id
execute if data storage manacore:ctrl arg run function manacore:internal/formation/find_scan
