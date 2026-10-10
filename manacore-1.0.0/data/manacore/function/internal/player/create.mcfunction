# ------------------------------------------------------------
# internal/player/create —— 按默认模板建立记录
# 【宏参数】manacore:work.a {uuid}
# 【做法】整份复制 config.defaults -> 覆盖 uuid -> 写入 players."uuid"
# 【想改新玩家初始属性】改 manacore:config.defaults.stats 即可。
# 【★ 2026-10-10 修 F16 ★】建记录的同时登记"终身清单"(manacore:players_all.list):
#   索引条目会随玩家离线被删(见 internal/leave/body), 记录却要留着 ⇒
#   必须有另一份"可遍历的名单", 否则 debug/reset_all 清不到离线的人。
#   ★ 本处是 5 个"建记录口"之一; **以后新增建记录的地方也要同样登记一行**。
#   不需要判重: 本函数只在 `unless data … players "$(uuid)"` 之后被调用, 同一记录只登记一次。
# ------------------------------------------------------------
data modify storage manacore:work record set from storage manacore:config defaults
$data modify storage manacore:work record.uuid set value "$(uuid)"
$data modify storage manacore:players "$(uuid)" set from storage manacore:work record
$data modify storage manacore:players_all list append value "$(uuid)"
