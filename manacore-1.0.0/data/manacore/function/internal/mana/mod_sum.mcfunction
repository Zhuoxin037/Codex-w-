# ------------------------------------------------------------
# internal/mana/mod_sum —— 把第 i 个修正加到本次恢复量
# 【宏参数】manacore:work.entry {uuid,i}
# 【作用】#m = 修正值 x1000, #regen += #m
# 【修正类型约定】type 字段只是给使用者分类用(equipment/passive/temporary/
#         special), 计算上不做区分——需要不同规则时在事件钩子里自行处理。
# ------------------------------------------------------------
$execute store result score #m manacore.math run data get storage manacore:players "$(uuid)".regen_mods."$(i)".value 1000
scoreboard players operation #regen manacore.math += #m manacore.math
