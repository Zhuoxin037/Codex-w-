# ============================================================
# sweetdream:debug/tg_fadd —— /trigger zx.dbg_fadd 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# ============================================================

scoreboard players set @s zx.dbg_fadd 0
tellraw @s [{"text":"[调试] /trigger 收到: 自己的术阵 +1","color":"dark_gray"}]
function sweetdream:debug/form_add
scoreboard players enable @s zx.dbg_fadd
