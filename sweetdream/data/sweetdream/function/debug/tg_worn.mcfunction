# ============================================================
# sweetdream:debug/tg_worn —— /trigger zx.dbg_worn 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# ============================================================

scoreboard players set @s zx.dbg_worn 0
tellraw @s [{"text":"[调试] /trigger 收到: 身上穿了什么","color":"dark_gray"}]
function sweetdream:debug/worn
scoreboard players enable @s zx.dbg_worn
