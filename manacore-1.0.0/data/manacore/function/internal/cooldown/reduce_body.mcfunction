# ------------------------------------------------------------
# internal/cooldown/reduce_body —— 实际修改 end
# 【宏参数】manacore:work.a {uuid,skill}; #amt 已算好
# 【守卫】只有该技能确实在冷却中(有 .end)才修改, 否则什么都不做 ——
#         这样"对没在冷却的技能减 CD"不会报错也不会产生脏数据。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end store result score #end manacore.math run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".end
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end run scoreboard players operation #end manacore.math -= #amt manacore.math
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end store result storage manacore:players "$(uuid)".cooldowns."$(skill)".end int 1 run scoreboard players get #end manacore.math
