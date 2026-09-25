# ------------------------------------------------------------
# internal/join/route —— 新老玩家分流
# 【宏参数】manacore:work.a {uuid,u0,u1,u2,u3}(由 uuid/build 产出的完整身份信息)
# 【逻辑】players 里已经有这个 UUID 的键 -> 老玩家(join/existing)
#         没有 -> 新玩家(join/new)
# 【为什么不用 if score】玩家数据全部按 UUID 文本存, 判断存在性最直观的
#         办法就是 data ... "uuid" 路径能不能取到值。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)" run function manacore:internal/join/existing with storage manacore:work a
$execute unless data storage manacore:players "$(uuid)" run function manacore:internal/join/new with storage manacore:work a
