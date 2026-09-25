# ============================================================
# api/mana/regen/modifier/add —— 添加一条魔力恢复修正
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", id:"my_pack:ring_mana",
#       type:"equipment", value:0.5}
#   function manacore:api/mana/regen/modifier/add
#   临时修正再加 duration / duration_seconds:
#   data modify storage manacore:in arg set value {uuid:"<UUID>", id:"my_pack:potion",
#       type:"temporary", value:3.0, duration_seconds:30}
#   function manacore:api/mana/regen/modifier/add
# 【type】仅作分类标记, 由你自己约定:
#   equipment(装备) / passive(被动技能) / temporary(临时) / special(特殊情况)
# 【出参】out.success(1b=写入成功, 0b=槽位已满) / out.index(占用槽位号)
# 【id 的用法】装备/技能用固定 id, 卸下时用 modifier/remove 按 id 精确移除。
# 【槽位数】默认 8 个; 满了会返回 success=0b, 请合并同类修正或扩容。
# ============================================================
# 出参: manacore:out.success / out.index
data modify storage manacore:work a set value {uuid:"",id:"",type:"equipment",value:0.0,duration:0,duration_seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.success set value 0b
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid if data storage manacore:work a.id run function manacore:internal/mana/mod_add with storage manacore:work a
