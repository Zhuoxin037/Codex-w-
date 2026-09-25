# ============================================================
# debug/on —— 打开调试模式(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/on
# 【效果】屏幕下方的 ActionBar 每秒刷新一次, 显示:
#         [ManaCore] 魔力 当前/上限  术阵 数量/上限  槽位 槽位号  UUID xxxxxxxx-...
# 【实现】① 给玩家加标签 manacore.debug(用于 @a 快速筛选, 零成本)
#         ② 同时在数据里置 debug=1b(reload 后仍然记得)
# 【为什么两处都记】标签在重载后会丢, 数据不会 —— 双保险。
# 【关掉】/function manacore:debug/off
# ============================================================
tag @s add manacore.debug
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0
function manacore:internal/debug/flag_on with storage manacore:work a
