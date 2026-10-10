# ------------------------------------------------------------
# internal/player/ensure —— 保证玩家记录存在
# 【宏参数】manacore:work.a {uuid}
# 【作用】记录不存在就用 config.defaults 建一份。这样所有写接口即使传入
#         一个从没登录过的 UUID, 也不会因为路径不存在而报错中断。
# 【注意】这里建出来的是"离线记录", 不会进索引, 也没有槽位; 等玩家真正
#         上线时会走 join/existing 补全。
# 【★ 空 uuid 守卫(2026-10-10, 修 F19)★】
#   uuid 必须是**存在的、且非空的**字符串才建记录。否则 `$(uuid)` 展开成空串,
#   会在 players 下建出 `players.""` 这种垃圾键, 而且此后每次空参数调用都认领它
#   (报告 F19 点名的就是这条)。第一个条件(键必须存在)还顺手挡住"宏展开失败"。
# ------------------------------------------------------------
$execute if data storage manacore:work a.uuid unless data storage manacore:work a{uuid:""} unless data storage manacore:players "$(uuid)" run function manacore:internal/player/create with storage manacore:work a
