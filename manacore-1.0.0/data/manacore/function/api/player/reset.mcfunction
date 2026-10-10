# ============================================================
# api/player/reset —— 重置某玩家的全部数据
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>"}
#   function manacore:api/player/reset
# 【效果】属性回到默认值, 术阵/冷却/恢复修正全部清空。
# 【风险】不可撤销。建议先 api/stats/export + debug/dump 留档。
# 【例外】不会动槽位索引; 若索引被清, 他下次上线会自动重新占槽。
# 【★ 应用层账本(2026-10-10, 修 F16)★】本接口只清 manacore 自己的数据。
#   应用层(sweetdream)的"已加成账本"(zx.am_mana / zx.chg_atk …)挂在玩家身上,
#   要清必须由**在线的那位玩家**执行 —— 见 #manacore:event/player_reset 与
#   sweetdream:event/player_reset(debug/reset_all 会逐个在线玩家派发它)。
#   单独调本接口时, 目标玩家在线的话请改用 debug/reset_all, 或事后让他重登。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/debug/reset_one with storage manacore:work a
