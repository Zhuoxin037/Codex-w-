# ------------------------------------------------------------
# internal/cooldown/increase_body —— 实际延后 end
# 【宏参数】manacore:work.a {uuid,skill}; #amt 已算好
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end store result score #end manacore.math run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".end
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end run scoreboard players operation #end manacore.math += #amt manacore.math
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end store result storage manacore:players "$(uuid)".cooldowns."$(skill)".end int 1 run scoreboard players get #end manacore.math
