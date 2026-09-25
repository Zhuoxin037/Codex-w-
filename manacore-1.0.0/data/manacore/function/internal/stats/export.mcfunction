# ------------------------------------------------------------
# internal/stats/export —— 导出某个玩家的全部属性
# 【宏参数】manacore:work.a {uuid}
# 【出参】manacore:out.stats(整份 stats 的副本) / out.uuid
# 【注意】这里是"复制", 改 out.stats 不会影响玩家本体数据。
# ------------------------------------------------------------
data modify storage manacore:out r.stats set value {}
$data modify storage manacore:out r.uuid set value "$(uuid)"
$execute if data storage manacore:players "$(uuid)".stats run data modify storage manacore:out r.stats set from storage manacore:players "$(uuid)".stats
