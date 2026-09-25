# ------------------------------------------------------------
# internal/leave/player —— 离线清理入口
# 【宏参数】manacore:work.a {uuid,slot}
# 【作用】先确认记录真的存在(防止索引里挂着一条已经被删掉的脏数据),
#         存在才执行 leave/body。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)" run function manacore:internal/leave/body with storage manacore:work a
