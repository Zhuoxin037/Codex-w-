# ------------------------------------------------------------
# internal/mana/force —— 强制恢复(特殊情况)
# 【宏参数】manacore:work.a {uuid,value}
# 【语义】无视恢复倍率、无视禁止恢复标记, 直接把 value 加到当前魔力上,
#         仍然受 max_mana 上限约束。
# 【典型场景】剧情回血、复活补魔、药剂瞬间回满但不想受"战斗禁疗"影响。
# 【对比】api/mana/regen/ban 只拦"自动恢复", 拦不住这里的强制恢复。
# ------------------------------------------------------------
execute store result score #m manacore.math run data get storage manacore:work a.value 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
scoreboard players operation #cur manacore.math += #m manacore.math
execute if score #cur manacore.math > #max manacore.math run scoreboard players operation #cur manacore.math = #max manacore.math
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
