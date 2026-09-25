# ============================================================
# api/formation/get —— 查询单个术阵的详情
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:fire_array"}
#          function manacore:api/formation/get
# 【出参】out.found / out.index / out.formation(整份术阵数据: id/type/owner/data/start/end)
# 【用途】读取 data 里的载荷(半径、伤害等)来做实际效果。
# ============================================================
data modify storage manacore:work a set value {uuid:"",id:""}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.found set value 0b
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/formation/get with storage manacore:work a
