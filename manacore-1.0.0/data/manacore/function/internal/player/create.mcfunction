# ------------------------------------------------------------
# internal/player/create —— 按默认模板建立记录
# 【宏参数】manacore:work.a {uuid}
# 【做法】整份复制 config.defaults -> 覆盖 uuid -> 写入 players."uuid"
# 【想改新玩家初始属性】改 manacore:config.defaults.stats 即可。
# ------------------------------------------------------------
data modify storage manacore:work record set from storage manacore:config defaults
$data modify storage manacore:work record.uuid set value "$(uuid)"
$data modify storage manacore:players "$(uuid)" set from storage manacore:work record
