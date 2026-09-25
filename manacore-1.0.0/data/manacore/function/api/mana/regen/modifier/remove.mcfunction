# ============================================================
# api/mana/regen/modifier/remove —— 按 id 移除恢复修正
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", id:"my_pack:ring_mana"}
#          function manacore:api/mana/regen/modifier/remove
# 【用途】卸装备、被动技能取消时调用。
# 【注意】id 相同的多条修正会被一次全删; 想让多个来源共存, 请给不同 id。
# ============================================================
data modify storage manacore:work a set value {uuid:"",id:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/mana/mod_remove with storage manacore:work a
