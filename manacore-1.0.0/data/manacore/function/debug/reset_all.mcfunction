# ============================================================
# debug/reset_all —— 【危险】清空全部玩家数据
# ------------------------------------------------------------
# 【用法】/function manacore:debug/reset_all
# 【效果】删掉所有玩家记录、索引、槽位回收池, 并重置槽位计数与在线玩家的
#   槽位号。所有人下次上线都会以新玩家身份重新开始。
# 【用途】测试环境重置 / 换季清档。
# 【不可恢复】执行前请务必先 /function manacore:api/stats/export_all 备份。
# ============================================================
scoreboard players set #mode manacore.meta 7
function manacore:internal/index/foreach
data modify storage manacore:free_slots list set value []
scoreboard players set #next_slot manacore.meta 0
scoreboard players reset @a manacore.slot
tellraw @s [{"text":"[ManaCore] 已清空全部玩家数据","color":"red"}]
