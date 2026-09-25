# ------------------------------------------------------------
# internal/mana/ban_perm —— 永久禁疗
# 【宏参数】manacore:work.a {uuid}
# 【解除方式】api/mana/regen/unban, 或直接把 flags.no_regen 改回 0b。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".flags.no_regen set value 1b
