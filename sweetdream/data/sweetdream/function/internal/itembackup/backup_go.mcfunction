# ============================================================
# sweetdream:internal/itembackup/backup_go —— 每秒快照的包装(以玩家身份执行)
# ------------------------------------------------------------
# 【谁调用它】lib/second(每秒)。老版的每刻 tick 进度循环(mainhand_1 + advancement
#   itembackup/mainhand)已随 O03 删除 —— 每秒一次足够: 两次消耗之间快照内容不会变,
#   真正"最准"的快照在消耗那一刻(effect_1 直接调宏本体 backup)。
# 【为什么要这层包装】backup 是**宏函数**($(uuid) 只能调用方传), 这里负责取 UUID、
#   备好 zx:work a 再 with storage 调它 —— 宏函数不能裸调(整函数作废、零日志)。
# 【开销】没拿 itemreplace 武器的人 = 取 uuid(纯存储/计分板, 免序列化) + 2 条
#   if items 谓词, 空转; 手上有武器的人 = 召/杀一个 Marker 临时架拷贝
#   (坑 95: 玩家物品不能直接 data 拷, 见 snap_main 头部) —— 每秒最多 2 次。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/backup with storage zx:work a
