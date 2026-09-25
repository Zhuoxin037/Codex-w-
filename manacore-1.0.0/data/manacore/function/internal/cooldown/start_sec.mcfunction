# ------------------------------------------------------------
# internal/cooldown/start_sec —— 秒级冷却换算
# 【原理】cooldown_seconds x 20 -> #dur(tick); 换算后再走同一条
#         start_go 流程, 所以"秒冷却"和"tick 冷却"后续处理完全一致。
# 【为什么只有 >0 才继续】冷却为 0 或负数表示"没有冷却", 不该写记录。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.cooldown_seconds 20
execute if score #dur manacore.math matches 1.. run function manacore:internal/cooldown/start_go with storage manacore:work a
