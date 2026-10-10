# ============================================================
# internal/debug/purge_one —— 清空单个玩家的全部数据(mode 7)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,slot}(由 index/visit 传入)
# 【做什么】① 删掉 players 里他的整份记录
#          ② 槽位还给回收池
#          ③ 删掉索引条目
# 【调用方】debug/reset_all, 通过 index/foreach 遍历逐个执行。
# 【★ 纠正(2026-10-10, 修 F16)★】原来这里写"无法删除某个存储的根"是**对的**
#   —— `/data remove storage <id>`(不带路径)会让整个函数加载失败(path 必填)。
#   (中途曾误以为"不带路径 = 删掉整个根", 已实测证伪: 报 "未知或不完整的命令"。
#    见 internal/debug/purge_registry 头部的实测日志。)
#   本函数保持"逐个删": 因为还要同时把槽位还回回收池、删掉索引条目 ——
#   这两件事只有逐个玩家做得了; 索引之外的离线残留由
#   internal/debug/purge_registry 按"终身清单"兜底。
# ============================================================
$execute if data storage manacore:players "$(uuid)" run data remove storage manacore:players "$(uuid)"
data modify storage manacore:free_slots list append from storage manacore:work a.slot
$execute if data storage manacore:index "$(slot)" run data remove storage manacore:index "$(slot)"
