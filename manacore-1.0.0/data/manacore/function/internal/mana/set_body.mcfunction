# ------------------------------------------------------------
# internal/mana/set_body —— 直接设置当前魔力
# 【宏参数】manacore:work.a {uuid,value}
# 【规则】结果会被夹取到 [0, max_mana]。想突破上限请改这里或直接用
#         internal/stats/set 写 current_mana。
# ------------------------------------------------------------
execute store result score #m manacore.math run data get storage manacore:work a.value 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
execute if score #m manacore.math > #max manacore.math run scoreboard players operation #m manacore.math = #max manacore.math
execute if score #m manacore.math matches ..0 run scoreboard players set #m manacore.math 0
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #m manacore.math
