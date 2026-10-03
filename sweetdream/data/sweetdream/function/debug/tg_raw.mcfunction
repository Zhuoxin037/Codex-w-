# ============================================================
# sweetdream:debug/tg_raw —— /trigger zx.dbg_raw 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# ============================================================

scoreboard players set @s zx.dbg_raw 0
function sweetdream:debug/raw
scoreboard players enable @s zx.dbg_raw
