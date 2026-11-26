# ============================================================
# fallendream:equipment/armor/frost_step/trigger —— 步霜：8 格兑现
# ------------------------------------------------------------
# 【谁调用它】frost_step/tick ⑦（累计到 800 时）
# 【执行者】玩家
# 【做什么】累加器清零 + 自身 4 格内的生物获得 2 秒缓慢 I。
#   ★ "生物"按包内口径 = 非玩家生物：@e[type=!#fallendream:no_damage]
#     （该标签天然含 minecraft:player；要连玩家得另加 @a，用户写的是"生物"）
#   ★ 缓慢 I = amplifier 0（0-based），2 秒；隐藏粒子。
# ============================================================

# ① 清零重计（= "触发一次并清零"）
scoreboard players set @s zx.fs_acc 0

# ② 4 格内生物缓慢 I 2 秒
execute at @s run effect give @e[type=!#fallendream:no_damage,distance=..4] minecraft:slowness 2 0 true

# ③ 表现
execute at @s run particle minecraft:snowflake ~ ~0.3 ~ 1.6 0.2 1.6 0.02 14 normal
