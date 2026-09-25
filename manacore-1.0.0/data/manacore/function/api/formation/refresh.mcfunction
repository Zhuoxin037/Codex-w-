# ============================================================
# api/formation/refresh —— 刷新术阵持续时间
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>",
#       id:"mypack:fire_array", duration_seconds:15}
#          function manacore:api/formation/refresh
# 【语义】把到期时间改成"现在 + 新时长"(不是叠加)。
# 【变永久】duration 与 duration_seconds 都给 0 -> 删掉 end 字段, 变永久术阵。
# 【出参】out.found / out.success
# 【用途】站在术阵上续时、技能叠层延长持续时间。
# ============================================================
data modify storage manacore:work a set value {uuid:"",id:"",duration:0,duration_seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.found set value 0b
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/formation/refresh with storage manacore:work a
