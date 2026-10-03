# ============================================================
# sweetdream:debug/tg_diff —— /trigger zx.dbg_diff 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# 【它是会写数据的】会更新快照 —— 但写的是 zx:data 下自己那一格, 不会碰面板。
# ============================================================

scoreboard players set @s zx.dbg_diff 0
function sweetdream:debug/diff
scoreboard players enable @s zx.dbg_diff
