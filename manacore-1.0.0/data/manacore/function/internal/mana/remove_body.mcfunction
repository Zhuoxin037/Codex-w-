# ------------------------------------------------------------
# internal/mana/remove_body —— 扣除魔力(不判定是否够用)
# 【宏参数】manacore:work.a {uuid,value}
# 【规则】current - value, 下限 0。
# 【如果你需要"魔力不足就别扣"的语义】请用 api/mana/consume, 它会返回
#         out.success 让你决定后续要不要执行技能。
# ------------------------------------------------------------
execute store result score #m manacore.math run data get storage manacore:work a.value 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
scoreboard players operation #cur manacore.math -= #m manacore.math
execute if score #cur manacore.math matches ..0 run scoreboard players set #cur manacore.math 0
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
