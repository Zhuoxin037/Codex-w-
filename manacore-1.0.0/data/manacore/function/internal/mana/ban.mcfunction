# ------------------------------------------------------------
# internal/mana/ban —— 禁止魔力恢复
# 【宏参数】manacore:work.a {uuid,ticks,seconds}
# 【两种模式】
#   ticks/seconds > 0  -> 限时: 写入 flags.regen_ban_end = #now + 时长,
#                         并清掉永久标记
#   ticks/seconds <=0  -> 永久: 置 flags.no_regen = 1b, 直到 unban 或道具解除
# 【判定位置】regen_apply 第 ③ 步。
# 【为什么两种字段都要】no_regen 表达"状态类禁疗"(例如被沉默),
#   regen_ban_end 表达"倒计时类禁疗"(例如喝药后的 5 秒冷却)。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.ticks
execute if score #dur manacore.math matches ..0 run function manacore:internal/mana/ban_sec
execute if score #dur manacore.math matches ..0 run function manacore:internal/mana/ban_perm with storage manacore:work a
execute if score #dur manacore.math matches 1.. run scoreboard players operation #dur manacore.math += #now manacore.meta
$execute if score #dur manacore.math matches 1.. store result storage manacore:players "$(uuid)".flags.regen_ban_end int 1 run scoreboard players get #dur manacore.math
$execute if score #dur manacore.math matches 1.. modify storage manacore:players "$(uuid)".flags.no_regen set value 0b
