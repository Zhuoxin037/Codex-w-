# ------------------------------------------------------------
# internal/formation\tick_expire —— 术阵自然到期
# 【宏参数】manacore:work.entry {uuid,i}
# 【步骤】① 把 id 写进事件上下文(缺失则填 "")
#         ② 槽位置空 {}
#         ③ 抛 #manacore:event/formation_remove, reason="expire"
# 【外部包收到事件后】销毁对应的显示实体/粒子/音效等副作用。
# 【为什么 reason 要区分】expire(自然到期) / remove(主动删除) /
#   clear(清空) / leave(玩家离线), 使用方可以按原因做不同表现。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)".id run data modify storage manacore:ctx id set from storage manacore:players "$(uuid)".formations."$(i)".id
$execute unless data storage manacore:players "$(uuid)".formations."$(i)".id run data modify storage manacore:ctx id set value ""
$data modify storage manacore:players "$(uuid)".formations."$(i)" set value {}
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "expire"
function #manacore:event/formation_remove
