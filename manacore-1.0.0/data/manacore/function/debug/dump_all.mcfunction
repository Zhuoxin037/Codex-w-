# ============================================================
# debug/dump_all —— 打印所有玩家的数据(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/dump_all
# 【实现】ctrl.mode = "dump" -> 遍历所有已登记槽位 -> 每人 dump 一份。
# 【注意】输出量很大, 建议只在排查问题时用; 大服上会刷屏。
# ============================================================
scoreboard players set #mode manacore.meta 5
function manacore:internal/index/foreach
