# ------------------------------------------------------------
# internal/mana/add_body —— 增加魔力(治疗/回复类)
# 【宏参数】manacore:work.a {uuid,value}
# 【规则】current + value, 上限 max_mana(不会溢出)。
# 【和自动恢复的区别】这条路径不受"禁止恢复"影响, 是主动加魔力。
# ------------------------------------------------------------
execute store result score #m manacore.math run data get storage manacore:work a.value 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
scoreboard players operation #cur manacore.math += #m manacore.math
execute if score #cur manacore.math > #max manacore.math run scoreboard players operation #cur manacore.math = #max manacore.math
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
