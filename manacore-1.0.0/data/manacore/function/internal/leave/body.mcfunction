# ------------------------------------------------------------
# internal/leave/body —— 离线清理的实际动作
# 【宏参数】manacore:work.a {uuid,slot}
# 【做了 5 件事】
#   ① session=0b   : 下次上线时会被判定为"需要重新注册"
#   ② slot=0       : 记录里的槽位号作废
#   ③ 槽位还给回收池 free_slots.list
#   ④ 删掉 index."slot" : 从此不再参与遍历(这是"不留残留"的关键)
#   ⑤ 清空该玩家的全部术阵(逐槽触发 formation_remove 事件, 让外部包
#      有机会销毁实体/粒子), 再抛 #manacore:event/player_leave
# 【保留什么】魔力、属性、冷却数据都会保留——玩家重新上线后接着用。
#         冷却用的是绝对时间戳, 离线期间自然走完。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".session set value 0b
$data modify storage manacore:players "$(uuid)".slot set value 0
data modify storage manacore:free_slots list append from storage manacore:work a.slot
$execute if data storage manacore:index "$(slot)" run data remove storage manacore:index "$(slot)"
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx id set value ""
data modify storage manacore:ctx reason set value "leave"
function manacore:internal/formation/clear_all with storage manacore:work a
function #manacore:event/player_leave
