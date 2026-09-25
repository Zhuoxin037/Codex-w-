# ------------------------------------------------------------
# internal/cooldown/apply_reduce —— 冷却缩减
# 【宏参数】manacore:work.a {uuid,reduce}
# 【读取】stats.cooldown_reduction, 约定为 0..1 的比例(0.25 = 缩减 25%)
# 【条件】只有 reduce=1b(本次释放允许吃缩减) 才生效 —— 方便做"某些技能
#         不吃冷却缩减"的设计, 调用时传 reduce:0b 即可。
# ------------------------------------------------------------
$execute if data storage manacore:work a{reduce:1b} store result score #red manacore.math run data get storage manacore:players "$(uuid)".stats.cooldown_reduction 1000
execute if data storage manacore:work a{reduce:1b} run function manacore:internal/cooldown/reduce_calc
