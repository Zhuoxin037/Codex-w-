# ------------------------------------------------------------
# internal/debug/export_all —— 导出全部玩家数据
# 【作用】把 manacore:players 整份复制到 manacore:out.players。
# 【用途】① 存档备份: 用 /data get storage manacore:out r.players.取出
#         ② 迁移: 复制到另一个存档的同名 storage
# 【注意】这只是引用复制, 之后的修改互不影响。
# ------------------------------------------------------------
data modify storage manacore:out r.players set value {}
scoreboard players set #mode manacore.meta 8
function manacore:internal/index/foreach
