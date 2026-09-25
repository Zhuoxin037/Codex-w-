# ------------------------------------------------------------
# internal/mana\remove_max_body —— 削减最大魔力(削弱/诅咒类)
# 【宏参数】manacore:work.a {uuid,value}
# 【步骤】max -= value(下限 0) -> 如果当前魔力已经超过新的上限, 顺带夹取。
# 【为什么要夹当前值】否则会出现"当前魔力 > 最大魔力"的非法状态,
#         debug/validate 会把这个状态报成警告。
# ------------------------------------------------------------
execute store result score #m manacore.math run data get storage manacore:work a.value 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
scoreboard players operation #max manacore.math -= #m manacore.math
execute if score #max manacore.math matches ..0 run scoreboard players set #max manacore.math 0
$execute store result storage manacore:players "$(uuid)".stats.max_mana double 0.001 run scoreboard players get #max manacore.math
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
execute if score #cur manacore.math > #max manacore.math run function manacore:internal/mana/clamp_cur with storage manacore:work a
