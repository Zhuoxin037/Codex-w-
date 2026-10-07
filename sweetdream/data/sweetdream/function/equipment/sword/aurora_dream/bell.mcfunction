# ============================================================
# sweetdream:equipment/sword/aurora_dream/bell —— 时停期间每秒推进 + 周期钟声
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[scores={zx.ad_bell=1..}] run 本函数
# 【文案补充】时停 12 秒里, "每隔几秒"给附近玩家响一次飘渺的钟声 ->
#   在剩余 12 / 9 / 6 / 3 秒时各响一次(共 4 次)。
# 【顺带每秒铺一层极光粒子】让整段时停都有氛围, 不只是起手那一下。
# ============================================================

# ① 到点的那几秒响钟声(先判再减, 所以 12 秒整开始)
execute if score @s zx.ad_bell matches 12 run function sweetdream:equipment/sword/aurora_dream/bell_sfx
execute if score @s zx.ad_bell matches 9 run function sweetdream:equipment/sword/aurora_dream/bell_sfx
execute if score @s zx.ad_bell matches 6 run function sweetdream:equipment/sword/aurora_dream/bell_sfx
execute if score @s zx.ad_bell matches 3 run function sweetdream:equipment/sword/aurora_dream/bell_sfx

# ② 每秒一层极光(施法者周围)
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 2.0 0.8 2.0 0.02 12 normal
execute at @s run particle minecraft:enchant ~ ~1.4 ~ 1.6 0.6 1.6 0.15 8 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1.1 ~ 1.8 0.6 1.8 0.03 6 normal

# ③ 倒计时归零
execute if score @s zx.ad_bell matches 1.. run scoreboard players remove @s zx.ad_bell 1
