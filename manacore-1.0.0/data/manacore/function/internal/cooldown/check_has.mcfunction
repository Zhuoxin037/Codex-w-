# ------------------------------------------------------------
# internal/cooldown/check_has —— 有冷却记录时的判定
# 【宏参数】manacore:work.a {uuid,skill}
# 【算法】#rem = end - #now
#         #rem >= 1  -> check_busy(还在冷却)
#         #rem <= 0  -> check_free(已到期)
# 【顺带清理】check_free 会删掉过期记录, 这就是本框架的"惰性清理"策略:
#         不做全局扫描, 谁被查到了就顺手把垃圾清掉。
#         (Minecraft 无法枚举任意键名, 这是唯一可行且高效的做法)
# ------------------------------------------------------------
$execute store result score #cd manacore.math run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".end
scoreboard players operation #rem manacore.math = #cd manacore.math
scoreboard players operation #rem manacore.math -= #now manacore.meta
execute if score #rem manacore.math matches 1.. run function manacore:internal/cooldown/check_busy with storage manacore:work a
execute if score #rem manacore.math matches ..0 run function manacore:internal/cooldown/check_free with storage manacore:work a
