# ============================================================
# api/formation/remove —— 删除指定玩家的指定术阵
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:fire_array"}
#          function manacore:api/formation/remove
# 【出参】out.removed = 1b(删掉了) / 0b(没找到)
# 【事件】会抛 #manacore:event/formation_remove(reason="remove"),
#   你的包记得在那里销毁对应的显示实体。
# ============================================================
data modify storage manacore:work a set value {uuid:"",id:""}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.removed set value 0b
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/formation/remove with storage manacore:work a
