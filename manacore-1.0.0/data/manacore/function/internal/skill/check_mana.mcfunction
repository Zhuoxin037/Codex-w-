# ------------------------------------------------------------
# internal/skill/check_mana —— 魔力是否够用(只读)
# 【宏参数】manacore:work.a {uuid,mana}
# 【逻辑】current_mana >= mana ? 保持 success=1b : check_nomana
# ------------------------------------------------------------
execute store result score #need manacore.math run data get storage manacore:work a.mana 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
execute if score #cur manacore.math < #need manacore.math run function manacore:internal/skill/check_nomana
