# ============================================================
# api/formation/force_remove —— 强制移除某玩家的术阵
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:fire_array"}
#          function manacore:api/formation/force_remove
# 【和 remove 的区别】remove 走"正常解除"语义, force_remove 表示"被强制
#   移除"(驱散/清场/GM)。两者都会清数据并抛事件, 事件里的 reason 都是
#   "remove", 你可以在自己的包里用不同的调用点区分意图。
# 【重要】即使该玩家已经离线也照样能删 —— 数据都在存储里, 不依赖实体。
# ============================================================
data modify storage manacore:work a set value {uuid:"",id:""}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.removed set value 0b
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/formation/remove with storage manacore:work a
