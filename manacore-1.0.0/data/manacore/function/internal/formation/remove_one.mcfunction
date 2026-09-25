# ------------------------------------------------------------
# internal/formation/remove_one —— 第 i 个槽位是否命中目标 id
# 【宏参数】manacore:work.entry {uuid,id,i}
# 【命中后】remove_hit 会清空槽位、写 out.removed / out.index 并抛事件。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)"{id:"$(id)"} run function manacore:internal/formation/remove_hit with storage manacore:work entry
