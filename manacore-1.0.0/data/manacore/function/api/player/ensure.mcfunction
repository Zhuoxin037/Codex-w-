# ============================================================
# api/player/ensure —— 确保玩家记录存在(内部工具)
# ------------------------------------------------------------
# 【读的是】manacore:work.a.uuid(当前宏参数节点), 而不是 manacore:in。
# 【为什么】所有写接口在分派前都会把参数放进 work.a, 由它统一兜底,
#   这样即使传入一个从没登录过的 UUID, 写入也不会因路径不存在而报错。
# 【正常使用不需要手动调用】api/mana/*, api/stats/*, api/skill/cast
#   内部都已经自动调用过它。
# ============================================================
execute if data storage manacore:work a.uuid run function manacore:internal/player/ensure with storage manacore:work a
