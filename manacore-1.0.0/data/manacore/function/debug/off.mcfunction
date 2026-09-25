# ============================================================
# debug/off —— 关闭调试模式(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/off
# 【效果】移除标签并清掉数据标记, ActionBar 不再刷新。
# ============================================================
tag @s remove manacore.debug
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0
function manacore:internal/debug/flag_off with storage manacore:work a
