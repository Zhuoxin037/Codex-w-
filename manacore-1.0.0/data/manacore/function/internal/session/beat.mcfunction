# ------------------------------------------------------------
# internal/session/beat —— 把心跳写进槽位索引(宏参数 {i})
# 【为什么走索引】离线玩家无法被当作实体操作, 所以"他是否还在线"必须
#   能在纯存储层面判断 —— 索引里的 beat 就是为此存在的。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run function manacore:internal/session/beat_write with storage manacore:index "$(i)"
