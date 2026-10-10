# ============================================================
# internal/debug/reset_all —— 【危险】清空全部玩家数据
# ------------------------------------------------------------
# 【用法】/function manacore:debug/reset_all
# 【效果】删掉所有玩家记录(在线 + 离线残留)、索引、槽位回收池, 并重置槽位计数与
#   在线玩家的槽位号。所有人下次上线都会以新玩家身份重新开始。
# 【用途】测试环境重置 / 换季清档。
# 【不可恢复】执行前请务必先 /function manacore:api/stats/export_all 备份。
# ------------------------------------------------------------
# 【★ 2026-10-10 修 F16 ★】
#   ① 原来只靠 index/foreach 遍历**索引**里的玩家 —— 而 internal/leave/body 会在
#      玩家离线时删掉他的索引条目(槽位要回收), 于是"离线玩家的 players 记录"
#      落在索引之外、遍历不到("已清空全部玩家数据"名不副实)。
#      现在改由 internal/debug/purge_registry 按"UUID 终身清单"
#      (manacore:players_all.list = 裸 uuid 字符串; 5 个"建记录口"各登记一行)
#      逐个删干净。
#      ★ 不要试图 `data remove storage manacore:players`(不带路径) ——
#        `/data remove` 的 <path> 是**必填**的, 那样写会让**整个函数加载失败**
#        (见 purge_registry 头部的实测报错)。存储的"根"在纯命令层面删不掉。
#   ② 应用层(sweetdream)那些"已加成账本"(zx.am_mana / zx.chg_atk …)挂在玩家身上,
#      manacore 清不到 ⇒ 底层属性被重置后装备**不会把加成加回来**。现在逐个在线
#      玩家抛 #manacore:event/player_reset, 由应用层收尾(见 internal/debug/reset_notify)。
#   ③ 离线玩家的应用层账本这一次清不到(见 event/player_reset 的注释)。
# ============================================================
scoreboard players set #mode manacore.meta 7
function manacore:internal/index/foreach
# 索引之外的残留(离线玩家) —— 按终身清单逐个删, 并清空清单
function manacore:internal/debug/purge_registry
data modify storage manacore:free_slots list set value []
scoreboard players set #next_slot manacore.meta 0
scoreboard players reset @a manacore.slot
# 逐个在线玩家 -> 应用层收尾事件(清 zx.* 账本, 见 event/player_reset)
execute as @a run function manacore:internal/debug/reset_notify
tellraw @s [{"text":"[ManaCore] 已清空全部玩家数据(含离线残留记录; 在线玩家的应用层账本已同步重置)","color":"red"}]
