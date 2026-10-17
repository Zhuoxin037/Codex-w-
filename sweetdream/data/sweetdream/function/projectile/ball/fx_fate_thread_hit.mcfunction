# ============================================================
# sweetdream:projectile/ball/fx_fate_thread_hit —— 《命缕》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】命缕 · 绯色丝线与缚命之声
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:dust{color:[0.78,0.12,0.22],scale:1.6} ~ ~ ~ 0.5 0.5 0.5 0.03 20 normal
particle minecraft:crit ~ ~ ~ 0.4 0.4 0.4 0.08 12 normal
particle minecraft:damage_indicator ~ ~ ~ 0.3 0.3 0.3 0.02 6 normal
playsound minecraft:entity.vex.ambient player @a ~ ~ ~ 0.55 1.2
