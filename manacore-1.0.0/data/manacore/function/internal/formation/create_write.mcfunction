# ============================================================
# internal/formation/create_write —— 把术阵写进槽位
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,id,type,i}(end 可选)
# 【写入内容】id / type / owner(=创建者 UUID) / data / start / end(可选)
# 【owner 的意义】任何时刻都能知道"这个术阵是谁的", 也是 force_remove、
#   find、离线清理能精准工作的原因。
# 【事件】抛 #manacore:event/formation_create, 你的包可以在那里:
#   生成显示实体/粒子、播放音效、登记到自己的副作用表。
#   注意: 前置包本身不生成任何实体, 视觉表现完全交给使用方。
# 【出参】out.success=1b / out.index=槽位号
# ============================================================
$data modify storage manacore:players "$(uuid)".formations."$(i)".id set value "$(id)"
$data modify storage manacore:players "$(uuid)".formations."$(i)".type set value "$(type)"
$data modify storage manacore:players "$(uuid)".formations."$(i)".owner set value "$(uuid)"
$data modify storage manacore:players "$(uuid)".formations."$(i)".data set value {}
$execute if data storage manacore:work a.data run data modify storage manacore:players "$(uuid)".formations."$(i)".data set from storage manacore:work a.data
$execute if data storage manacore:work a.end run data modify storage manacore:players "$(uuid)".formations."$(i)".end set from storage manacore:work a.end
$execute store result storage manacore:players "$(uuid)".formations."$(i)".start int 1 run scoreboard players get #now manacore.meta
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.reason set value "ok"
execute store result storage manacore:out r.index int 1 run data get storage manacore:work a.i
$data modify storage manacore:ctx id set value "$(id)"
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "create"
function #manacore:event/formation_create
