# ------------------------------------------------------------
# internal/formation/clear_one —— 第 i 个槽位若占用则清除
# 【宏参数】manacore:work.entry {uuid,i}
# 【注意】判定字段是 id(空槽没有 id), 不是整个槽位是否存在。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)".id run function manacore:internal/formation/clear_step with storage manacore:work entry
