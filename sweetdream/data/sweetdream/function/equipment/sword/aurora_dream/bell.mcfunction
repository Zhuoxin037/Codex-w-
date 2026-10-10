# ============================================================
# sweetdream:equipment/sword/aurora_dream/bell —— 时停期间每秒推进 + 周期钟声
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[scores={zx.ad_bell=1..}] run 本函数
# 【文案补充】时停 12 秒里, "每隔几秒"给附近玩家响一次飘渺的钟声 ->
#   ★ 2026-10-09 改为**稳定 4 秒一次** ★: 起手那一声由 cast ⑦ 负责,
#     本函数只补后面两声 -> 时间轴上落在 0 / 4 / 8 秒(共 3 声, 间隔都是 4 秒)。
# 【顺带每秒铺一层极光粒子】让整段时停都有氛围, 不只是起手那一下。
# ============================================================

# ① 到点的那几秒响钟声 —— **稳定 4 秒一次**(先判再减)
#   ★ 为什么**没有** matches 12 那一行(刻意省略, 别补回来):
#     cast 当刻已经响过一声(cast ⑦ 的 bell.use), 而本函数挂在"每秒"入口上,
#     执行时机与 cast 之间可能只差 1 秒 —— 若这里再判 12, 就会出现
#     "起手一声, 隔 1 秒又一声"的**不均匀**节奏(玩家听到的就是"变密了")。
#   ★ 判值为什么是 9 / 5 (而不是直觉的 8 / 4): 本函数是**先判后减**,
#     cast 设 ad_bell=12, 第 n 秒判到的值是 13-n
#     ⇒ matches 9 落在起手后第 **4** 秒, matches 5 落在第 **8** 秒 ——
#     正好 4 秒一声, 且都不会和 cast 的第 0 声撞车。
#     删掉多余项之后: 0(cast) / 4 / 8, 三声间隔全是 4 秒。
execute if score @s zx.ad_bell matches 9 run function sweetdream:equipment/sword/aurora_dream/bell_sfx
execute if score @s zx.ad_bell matches 5 run function sweetdream:equipment/sword/aurora_dream/bell_sfx

# ② 每秒一层极光(施法者周围)
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 2.0 0.8 2.0 0.02 12 normal
execute at @s run particle minecraft:enchant ~ ~1.4 ~ 1.6 0.6 1.6 0.15 8 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1.1 ~ 1.8 0.6 1.8 0.03 6 normal

# ③ 倒计时归零
execute if score @s zx.ad_bell matches 1.. run scoreboard players remove @s zx.ad_bell 1
