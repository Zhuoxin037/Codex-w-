# ------------------------------------------------------------
# internal/formation/tick_one —— 第 i 个槽位的到期预检
# 【宏参数】manacore:work.entry {uuid,i}
# 【判断】只有带 end 字段(限时术阵)才需要比较时间。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".formations."$(i)".end run function manacore:internal/formation/tick_check with storage manacore:work entry
