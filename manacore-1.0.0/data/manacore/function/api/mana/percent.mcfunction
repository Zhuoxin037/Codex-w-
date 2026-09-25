# ============================================================
# api/mana/percent —— 当前魔力百分比
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/mana/percent
# 【出参】out.value = 0..1 的小数(例如 0.625)
# 【用途】画魔力条/决定变色阈值(低于 30% 变红之类)。
# 【除零保护】max_mana 为 0 时返回 0。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/mana/percent with storage manacore:work a
