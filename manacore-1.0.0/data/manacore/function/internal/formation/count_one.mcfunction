# ------------------------------------------------------------
# internal/formation/count_one —— 第 i 个槽位是否有术阵
# 【宏参数】manacore:work.entry {uuid,i}
# 【作用】有 id 字段 -> #count += 1
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)".id run scoreboard players add #count manacore.math 1
