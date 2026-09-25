# ============================================================
# api/mana/get —— 读取当前魔力与最大魔力
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>"}
#   function manacore:api/mana/get
#   读取: /data get storage manacore:out r.value   (当前)
#         /data get storage manacore:out r.max     (上限)
# 【用途】做魔力条 UI 时每秒读一次即可。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/mana/get with storage manacore:work a
