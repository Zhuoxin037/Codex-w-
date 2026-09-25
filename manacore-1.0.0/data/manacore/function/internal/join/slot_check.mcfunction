# ------------------------------------------------------------
# internal/join/slot_check —— 槽位是否仍属于我
# 【宏参数】manacore:macro.a {uuid,u0,u1,u2,u3,cur,slot}
# 【判断】index."cur".uuid == 我的 uuid ?
#         是  -> register(沿用原槽位, 数据不丢)
#         否  -> reissue(说明槽位被别人用了 / 上次异常退出被回收了, 重新分配)
# 【为什么需要这一步】玩家退出后槽位会被回收给别人; 而他的计分板里还留着
#         旧槽位号。如果直接信任计分板, 就会把别人索引里的 uuid 覆盖掉。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(cur)"{uuid:"$(uuid)"} run function manacore:internal/join/register with storage manacore:macro a
$execute unless data storage manacore:index "$(cur)"{uuid:"$(uuid)"} run function manacore:internal/join/reissue with storage manacore:macro a
