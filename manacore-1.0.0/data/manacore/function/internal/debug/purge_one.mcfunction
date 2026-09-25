# ============================================================
# internal/debug/purge_one —— 清空单个玩家的全部数据(mode 7)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,slot}(由 index/visit 传入)
# 【做什么】① 删掉 players 里他的整份记录
#          ② 槽位还给回收池
#          ③ 删掉索引条目
# 【调用方】debug/reset_all, 通过 ctrl 遍历逐个执行。
# 【为什么不用一条命令清空 players】NBT 路径必须有具体键名,
#   无法"删除某个存储的根", 所以只能遍历删除。
# ============================================================
$execute if data storage manacore:players "$(uuid)" run data remove storage manacore:players "$(uuid)"
data modify storage manacore:free_slots list append from storage manacore:work a.slot
$execute if data storage manacore:index "$(slot)" run data remove storage manacore:index "$(slot)"
