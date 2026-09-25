# ------------------------------------------------------------
# internal/mana/sum_add —— 把第 i 个槽位的 value 累加到 #sum
# 【宏参数】manacore:work.entry {uuid,i}
# ------------------------------------------------------------
$execute store result score #m manacore.math run data get storage manacore:players "$(uuid)".regen_mods."$(i)".value 1000
scoreboard players operation #sum manacore.math += #m manacore.math
