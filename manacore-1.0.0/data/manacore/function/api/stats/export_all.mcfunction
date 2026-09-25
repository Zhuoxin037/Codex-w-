# ============================================================
# api/stats/export_all —— 导出所有玩家的全部数据
# ------------------------------------------------------------
# 【调用】function manacore:api/stats/export_all
# 【结果】/data get storage manacore:out r.players
# 【用途】整包备份/迁移。
# 【提醒】大服上会产生一大坨 NBT, 建议按需/定期执行, 不要放进每秒循环。
# ============================================================
data modify storage manacore:out r.players set value {}
function manacore:internal/debug/export_all
