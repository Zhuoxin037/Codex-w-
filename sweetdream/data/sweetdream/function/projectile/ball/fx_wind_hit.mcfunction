# ============================================================
# sweetdream:projectile/ball/fx_wind_hit —— "风" 法球命中的表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ④ 步(执行者/位置 = 法球, 也就是命中点)
# 【画的是什么】炸开一大团风 + 几粒火花, 配一声风弹爆开的闷响。
# 【音效名是核对过的】entity.wind_charge.wind_burst 在 1.21.5 的
#   assets/minecraft/sounds.json 里确实存在, 不是猜的。
# ============================================================

particle minecraft:gust ~ ~ ~ 0.6 0.5 0.6 0.05 12 normal
particle minecraft:small_gust ~ ~ ~ 0.9 0.4 0.9 0.08 22 normal
particle minecraft:crit ~ ~ ~ 0.4 0.4 0.4 0.05 8 normal
playsound minecraft:entity.wind_charge.wind_burst player @a ~ ~ ~ 0.85 1.15
