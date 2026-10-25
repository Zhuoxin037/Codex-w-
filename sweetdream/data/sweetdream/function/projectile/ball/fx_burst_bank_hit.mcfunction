# ============================================================
# sweetdream:projectile/ball/fx_burst_bank_hit —— 《决堤》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】决堤 · 溃开的水与泥沙
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:splash ~ ~ ~ 0.55 0.5 0.55 0.06 24 normal
particle minecraft:bubble ~ ~ ~ 0.45 0.4 0.45 0.02 16 normal
particle minecraft:dust{color:[0.5,0.68,0.64],scale:1.5} ~ ~ ~ 0.5 0.5 0.5 0.04 16 normal
playsound minecraft:entity.fishing_bobber.splash player @a ~ ~ ~ 0.75 0.85
