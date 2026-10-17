# ============================================================
# sweetdream:equipment/armor/rain_trace/stay —— 离开水迹的生物要"退出停留"
# ------------------------------------------------------------
# 【谁调用它】core/tick（每刻一次）
# 【判据】zx.rt_end < #now ⇒ 已经 8 刻（0.4 秒）没被任何水迹点覆盖过 ⇒ 置 0
# 【★ 为什么 rt_on 用 1.. 而不是 =1 ★】已兑现的 2 也必须能被清回 0，
#   否则同一只生物再站进另一段水迹时永远不会重新计时（静默"只生效一次"）。
# 【★ 三维度各写一遍 ★】选择器只在执行维度里搜索（core/tick 跑在主世界），
#   只写一行的话，下界/末地的水迹生物永远不会被清，rt_on 会一直卡在 1。
# ============================================================

execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,distance=0..,scores={zx.rt_on=1..}] if score @s zx.rt_end < #now manacore.meta run scoreboard players set @s zx.rt_on 0
execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,distance=0..,scores={zx.rt_on=1..}] if score @s zx.rt_end < #now manacore.meta run scoreboard players set @s zx.rt_on 0
execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,distance=0..,scores={zx.rt_on=1..}] if score @s zx.rt_end < #now manacore.meta run scoreboard players set @s zx.rt_on 0
