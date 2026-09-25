# ============================================================
# api/formation/force_remove_all —— 全服移除某个 id 的术阵
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {id:"mypack:fire_array"}
#          function manacore:api/formation/force_remove_all
# 【实现】遍历所有已登记槽位, 每个玩家查一次该 id, 命中就删并抛事件。
# 【用途】① 管理员清场 ② 全局驱散(例如某个 BOSS 登场时清掉所有场地效果)
# 【注意】会遍历全部在线+离线玩家的记录, 属于"重操作", 不要放进循环里。
# ============================================================
data modify storage manacore:ctrl arg set value ""
execute if data storage manacore:in arg.id run data modify storage manacore:ctrl arg set from storage manacore:in arg.id
execute if data storage manacore:ctrl arg run function manacore:internal/formation/remove_scan
