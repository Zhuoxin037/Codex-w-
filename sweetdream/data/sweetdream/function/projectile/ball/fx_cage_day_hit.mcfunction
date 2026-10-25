# ============================================================
# sweetdream:projectile/ball/fx_cage_day_hit —— 《囚昼》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】囚昼 · 暗紫的囚光
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:end_rod ~ ~ ~ 0.5 0.5 0.5 0.05 20 normal
particle minecraft:dust{color:[0.5,0.24,0.72],scale:1.6} ~ ~ ~ 0.55 0.5 0.55 0.04 20 normal
particle minecraft:reverse_portal ~ ~ ~ 0.4 0.4 0.4 0.03 10 normal
playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.55 1.15
