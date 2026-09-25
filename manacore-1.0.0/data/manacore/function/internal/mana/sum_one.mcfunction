# ------------------------------------------------------------
# internal/mana/sum_one —— 累加第 i 个槽位(空槽位自动跳过)
# 【宏参数】manacore:work.entry {uuid,i}
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".regen_mods."$(i)".value run function manacore:internal/mana/sum_add with storage manacore:work entry
