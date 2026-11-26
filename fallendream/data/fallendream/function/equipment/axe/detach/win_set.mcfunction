# ============================================================
# fallendream:equipment/axe/detach/win_set —— 记 8 秒窗口（切换之后）
# ------------------------------------------------------------
# 【宏参数】zx:work detach {u:"<被命中的生物 UUID>"}
# 【执行者】玩家（已是同生体）
# 【两侧】
#   · 玩家侧 zx.dt_win  = 到期刻（刻）。hit 用它当**廉价闸门**，没窗口就一次空转。
#   · 生物侧 zx.dt_wend = 还剩几秒（win_tick 每秒 -1，归零自己 reset）。
#     记在生物身上，所以"施放者中途死了"也不会留下永久标记。
# 【★ 同一时刻只留一个待兑现目标 ★】冷却 20 秒 > 窗口 8 秒，正常不会有第二个；
#   这里仍先清全场，防止跨维度残留（三维度各写一遍是 second 那边的老规矩）。
# ============================================================

scoreboard players operation @s zx.dt_win = #now manacore.meta
scoreboard players add @s zx.dt_win 160

execute in minecraft:overworld as @e[scores={zx.dt_wend=1..},distance=0..] run scoreboard players reset @s zx.dt_wend
execute in minecraft:the_nether as @e[scores={zx.dt_wend=1..},distance=0..] run scoreboard players reset @s zx.dt_wend
execute in minecraft:the_end as @e[scores={zx.dt_wend=1..},distance=0..] run scoreboard players reset @s zx.dt_wend

$scoreboard players set $(u) zx.dt_wend 8
