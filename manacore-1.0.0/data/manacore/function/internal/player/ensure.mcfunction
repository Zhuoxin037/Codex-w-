# ------------------------------------------------------------
# internal/player/ensure —— 保证玩家记录存在
# 【宏参数】manacore:work.a {uuid}
# 【作用】记录不存在就用 config.defaults 建一份。这样所有写接口即使传入
#         一个从没登录过的 UUID, 也不会因为路径不存在而报错中断。
# 【注意】这里建出来的是"离线记录", 不会进索引, 也没有槽位; 等玩家真正
#         上线时会走 join/existing 补全。
# ------------------------------------------------------------
$execute unless data storage manacore:players "$(uuid)" run function manacore:internal/player/create with storage manacore:work a
