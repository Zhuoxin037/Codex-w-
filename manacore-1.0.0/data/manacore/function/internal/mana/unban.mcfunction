# ------------------------------------------------------------
# internal/mana/unban —— 解除全部禁疗
# 【宏参数】manacore:work.a {uuid}
# 【做法】永久标记与限时时间戳一起清掉, 保证不会有残留状态卡住恢复。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".flags.no_regen set value 0b
$data modify storage manacore:players "$(uuid)".flags.regen_ban_end set value 0
