# ------------------------------------------------------------
# internal/mana/regen_one —— 处理第 i 个恢复修正槽位
# 【宏参数】manacore:work.entry {uuid,i}
# 【判断】只有该槽位有 value 字段时才继续(空槽位是 {}), 否则直接跳过。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".regen_mods."$(i)".value run function manacore:internal/mana/regen_use with storage manacore:work entry
