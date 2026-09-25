# ============================================================
# core/player/join —— 玩家注册入口(必须以 @s 执行)
# ------------------------------------------------------------
# 【为什么需要】命令无法直接读到玩家名字, 也无法把 UUID 变成字符串,
#         所以框架用"把 UUID 的 4 个整数拆成 32 位十六进制"的办法,
#         自己造出标准 UUID 文本(8-4-4-4-12), 用它当存储键。
# 【三步】
#   collect : data get entity @s UUID[0..3] -> manacore:work.a.u0..u3
#   build   : 32 次半字节查表拼接 -> work.a.hex -> work.a.uuid
#   route   : 记录已存在 -> join/existing(老玩家); 不存在 -> join/new(新玩家)
# 【成本】一次注册约 700 条命令, 但只在"玩家上线"时跑一次(不是每刻),
#         所以完全可以接受。
# 【注意】任何需要"某个玩家的 UUID"的代码, 都不应该自己重算一遍,
#         直接读 manacore:index."<槽位>".uuid 或 players 的键即可。
# ============================================================
function manacore:internal/uuid/collect
function manacore:internal/uuid/build
function manacore:internal/join/route with storage manacore:work a
