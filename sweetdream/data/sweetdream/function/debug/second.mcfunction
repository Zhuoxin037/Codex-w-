# ============================================================
# sweetdream:debug/second —— 每秒要做的事(挂在 #manacore:event/second 的最后一条)
# ------------------------------------------------------------
# 【为什么它在列表最后】它干两件事, 两件都要求"排在所有装备的每秒逻辑之后":
#   ① 回魔账本翻页: 本秒各家装备往 zx.regen_extra 累加完了 -> 抄进 regen_last
#      再清零。于是 regen_last 永远是"上一秒完整的一秒"实收了多少,
#      谁读它都不受 event/second 列表顺序的影响。
#   ② 把 /trigger 项重新打开。
#
# 【为什么要每秒开一次 /trigger】
#   ① 原版 trigger 被用掉一次就自动 disable; 不重开就每人只能按一次。
#   ② 刚进服的人 / /reload 之后的人也需要有。
#   ③ 只在 load 里开一次不够 —— 那时还没上线的人不会被执行到。
# 【开销】十来条命令/秒, 不吃实体遍历, 可以忽略。
# ============================================================

# ---- ① 回魔账本翻页 ----
#   【为什么不用 @a @a 两边都写选择器】scoreboard operation 的 target 和 source
#   都写多目标时语义容易踩坑(会按"每个 target 配每个 source"配对), 拆开写最稳。
execute as @a run scoreboard players operation @s zx.regen_last = @s zx.regen_extra
scoreboard players set @a zx.regen_extra 0

# ---- ② 重新打开所有 /trigger 调试入口 ----
#   ★ 加了新入口, 记得在这里也加一行 enable ★
scoreboard players enable @a zx.dbg_stats
scoreboard players enable @a zx.dbg_worn
scoreboard players enable @a zx.dbg_raw
scoreboard players enable @a zx.dbg_diff
scoreboard players enable @a zx.dbg_cd
scoreboard players enable @a zx.dbg_mana
scoreboard players enable @a zx.dbg_menu
scoreboard players enable @a zx.dbg_give
