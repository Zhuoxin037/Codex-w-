# ============================================================
# sweetdream:projectile/ball/fx_palette_hit —— 《调色盘》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】三色 · 红黄蓝同时撒出
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:dust{color:[1.0,0.25,0.3],scale:1.6} ~ ~ ~ 0.55 0.5 0.55 0.05 10 normal
particle minecraft:dust{color:[1.0,0.85,0.2],scale:1.6} ~ ~ ~ 0.55 0.5 0.55 0.05 10 normal
particle minecraft:dust{color:[0.3,0.55,1.0],scale:1.6} ~ ~ ~ 0.55 0.5 0.55 0.05 10 normal
particle minecraft:firework ~ ~ ~ 0.5 0.4 0.5 0.06 8 normal
playsound minecraft:entity.firework_rocket.twinkle player @a ~ ~ ~ 0.7 1.5
