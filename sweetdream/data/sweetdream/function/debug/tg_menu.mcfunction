# ============================================================
# sweetdream:debug/tg_menu —— /trigger zx.dbg_menu 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# 【菜单本身是可点击的】条目表在 lib/reg/build 的 menu 里, 画在 debug/menu。
# ============================================================

scoreboard players set @s zx.dbg_menu 0
function sweetdream:debug/menu
scoreboard players enable @s zx.dbg_menu
