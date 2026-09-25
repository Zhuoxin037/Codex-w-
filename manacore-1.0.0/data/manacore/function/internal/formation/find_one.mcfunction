# ------------------------------------------------------------
# internal/formation/find_one —— 第 i 个槽位是否就是目标 id
# 【宏参数】manacore:work.entry {uuid,id,i}
# 【判断】用 {id:"$(id)"} 做复合精确匹配。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)"{id:"$(id)"} run function manacore:internal/formation/find_hit with storage manacore:work entry
