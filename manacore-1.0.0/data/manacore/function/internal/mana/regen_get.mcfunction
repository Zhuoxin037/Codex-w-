# ------------------------------------------------------------
# internal/mana/regen_get —— 查询恢复参数(调试/UI 用)
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.value = 基础每秒恢复
#         out.multiplier = 恢复倍率
#         out.bonus = 8 个修正槽位的合计(不含倍率)
# 【注意】这里只统计"当前生效"的修正值, 不做过期清理(清理在每秒 tick 里)。
# ------------------------------------------------------------
$execute store result score #regen manacore.math run data get storage manacore:players "$(uuid)".stats.mana_regen 1000
execute store result storage manacore:out r.value double 0.001 run scoreboard players get #regen manacore.math
$execute store result score #mult manacore.math run data get storage manacore:players "$(uuid)".stats.mana_regen_multiplier 1000
execute store result storage manacore:out r.multiplier double 0.001 run scoreboard players get #mult manacore.math
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0}
function manacore:internal/mana/sum_driver with storage manacore:work entry
execute store result storage manacore:out r.bonus double 0.001 run scoreboard players get #sum manacore.math
