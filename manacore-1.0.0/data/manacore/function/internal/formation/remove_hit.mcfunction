# ------------------------------------------------------------
# internal/formation/remove_hit —— 删除命中: 清槽 + 事件
# 【宏参数】manacore:work.entry {uuid,id,i}
# 【出参】out.removed = 1b / out.index = 槽位号
# 【事件】#manacore:event/formation_remove(reason="remove")
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".formations."$(i)" set value {}
$data modify storage manacore:ctx id set value "$(id)"
$data modify storage manacore:ctx uuid set value "$(uuid)"
execute store result storage manacore:out r.index int 1 run data get storage manacore:work entry.i
data modify storage manacore:out r.removed set value 1b
data modify storage manacore:ctx reason set value "remove"
function #manacore:event/formation_remove
