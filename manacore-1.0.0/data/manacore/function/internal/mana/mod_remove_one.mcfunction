# ------------------------------------------------------------
# internal/mana/mod_remove_one —— 命中同 id 就清空该槽位
# 【宏参数】manacore:work.entry {uuid,id,i}
# 【判断】用 {id:"$(id)"} 做复合匹配, 只有 id 完全相同才清空。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".regen_mods."$(i)"{id:"$(id)"} run data modify storage manacore:players "$(uuid)".regen_mods."$(i)" set value {}
