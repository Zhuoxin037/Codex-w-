# ============================================================
# sweetdream:debug/freeze_one —— 报一只生物的"还剩几 tick"(冷冻 / 时停通用)
# ------------------------------------------------------------
# 【执行者】被冻住 / 被时停的那只生物(由 debug/freeze 逐个调)
# 【剩余怎么算】zx.fz_end(它该收效果的时刻) - #now(框架时钟) = 还剩几 tick
#   计分项不能直接做减法到显示上, 所以先算进临时计分项 #fz 再读出来。
# ============================================================

scoreboard players operation #fz zx.meta = @s zx.fz_end
scoreboard players operation #fz zx.meta -= #now manacore.meta
tellraw @a [{"selector":"@s"},{"text":"  剩余 ","color":"gray"},{"score":{"name":"#fz","objective":"zx.meta"},"color":"white"},{"text":" tick","color":"dark_gray"}]
