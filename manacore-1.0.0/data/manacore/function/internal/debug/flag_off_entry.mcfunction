# ------------------------------------------------------------
# internal/debug/flag_off_entry —— 调试关闭(已确认身份)
# 【宏参数】索引条目 {uuid}
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".debug set value 0b
tellraw @s [{"text":"[ManaCore] 调试模式: ","color":"gray"},{"text":"关闭","color":"white"}]
