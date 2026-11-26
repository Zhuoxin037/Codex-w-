# ============================================================
# fallendream:projectile/ball/fx_lucid_illusion_hit —— 《清醒与幻觉》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】清醒镜面与紫色幻影
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:reverse_portal ~ ~ ~ 0.35 0.4 0.35 0.04 12 normal
particle minecraft:end_rod ~ ~ ~ 0.2 0.3 0.2 0.02 6 normal
playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.65 1.6
