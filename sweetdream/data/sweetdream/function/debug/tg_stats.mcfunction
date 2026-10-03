# ============================================================
# sweetdream:debug/tg_stats —— /trigger zx.dbg_stats 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable。
#   反过来的话, 万一中间哪一步出错中断了, 玩家会永远卡在"分数还是 1"的
#   状态里每刻重复触发(而且他还要再敲一次 /trigger 才可能救回来)。
# 【注意】debug/stats 自己是只读的, 所以这里不需要防重入。
# ============================================================

scoreboard players set @s zx.dbg_stats 0
tellraw @s [{"text":"[调试] /trigger 收到: 查看自己的全部数值","color":"dark_gray"}]
function sweetdream:debug/stats
scoreboard players enable @s zx.dbg_stats
