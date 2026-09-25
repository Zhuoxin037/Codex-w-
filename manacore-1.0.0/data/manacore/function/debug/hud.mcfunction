# ============================================================
# debug/hud —— 立刻刷新一次调试 HUD(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/hud
# 【说明】平时 HUD 是每秒自动刷新的; 这个入口用于"手动立即刷一次"
#   (例如刚改完属性想看效果)。
# 【原理】把自己的槽位号读出来, 交给内部宏去查 UUID 并画 ActionBar。
# ============================================================
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0
function manacore:internal/debug/hud with storage manacore:work a
