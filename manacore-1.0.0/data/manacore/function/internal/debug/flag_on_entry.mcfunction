# ------------------------------------------------------------
# internal/debug/flag_on_entry —— 调试开启(已确认身份)
# 【宏参数】索引条目 {uuid}
# 【作用】写标记 + 给执行者一条反馈消息。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".debug set value 1b
tellraw @s [{"text":"[ManaCore] 调试模式: ","color":"green"},{"text":"开启","color":"white"},{"text":" (HUD 每秒刷新)","color":"gray"}]
