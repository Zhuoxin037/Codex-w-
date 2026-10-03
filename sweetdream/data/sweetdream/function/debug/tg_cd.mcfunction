# ============================================================
# sweetdream:debug/tg_cd —— /trigger zx.dbg_cd 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# 【cd_clear 里可能 return】它的 return 只结束它自己, 不影响这里 ——
#   "手上不是本包武器"时它会打印一句提示然后把控制权还回来。
# ============================================================

scoreboard players set @s zx.dbg_cd 0
tellraw @s [{"text":"[调试] /trigger 收到: 结束主手武器的冷却","color":"dark_gray"}]
function sweetdream:debug/cd_clear
scoreboard players enable @s zx.dbg_cd
