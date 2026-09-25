# ------------------------------------------------------------
# internal/debug/check_mana —— 校验 current_mana <= max_mana
# 【宏参数】manacore:work.a {uuid}
# 【实现】两个值都 x1000 转成整数后用计分板比较。
# ------------------------------------------------------------
$execute store result score #v_cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
$execute store result score #v_max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
execute if score #v_cur manacore.math > #v_max manacore.math run function manacore:internal/debug/warn_mana with storage manacore:work a
