# ============================================================
# sweetdream:projectile/ball/fx_twilight_hit —— 《暮光》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】黄昏 · 紫与橙的双色
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【命中音在哪】本文件**故意不播音效**。暮光普攻命中本身是静音的,
#    只有 20% 触发「噬心」时才出声 —— 那一下在
#    sweetdream:equipment/staff/twilight/tw_proc.mcfunction 第 ③ 步。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:dust{color:[0.62,0.26,0.78],scale:1.6} ~ ~ ~ 0.55 0.5 0.55 0.05 18 normal
particle minecraft:dust{color:[1.0,0.55,0.2],scale:1.4} ~ ~ ~ 0.55 0.5 0.55 0.05 14 normal
particle minecraft:smoke ~ ~ ~ 0.5 0.45 0.5 0.02 8 normal
