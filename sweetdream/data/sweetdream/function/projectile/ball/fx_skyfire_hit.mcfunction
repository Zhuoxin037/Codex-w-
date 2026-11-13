# ============================================================
# sweetdream:projectile/ball/fx_skyfire_hit —— 《天火》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】天火 · 坠落的橙红火种
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:flame ~ ~ ~ 0.5 0.4 0.5 0.05 20 normal
particle minecraft:smoke ~ ~ ~ 0.4 0.3 0.4 0.02 8 normal
playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.7 1.2
