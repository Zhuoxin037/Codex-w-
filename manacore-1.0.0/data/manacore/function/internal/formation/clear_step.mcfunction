# ------------------------------------------------------------
# internal/formation/clear_step —— 单个术阵的清除动作
# 【宏参数】manacore:work.entry {uuid,i}
# 【为什么要拆成两步】"槽位存在"与"槽位里真的有术阵"是两件事;
#   clear_one 先确认占用, 这里的 .id 取值就不会报错中断。
# ------------------------------------------------------------
$data modify storage manacore:ctx id set from storage manacore:players "$(uuid)".formations."$(i)".id
$data modify storage manacore:players "$(uuid)".formations."$(i)" set value {}
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "clear"
function #manacore:event/formation_remove
