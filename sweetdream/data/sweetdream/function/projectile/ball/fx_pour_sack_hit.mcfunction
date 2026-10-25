# ============================================================
# sweetdream:projectile/ball/fx_pour_sack_hit —— 《倾囊》的命中表现
# ------------------------------------------------------------
# 【谁调用它】ball/hit 第 ⑤ 步(执行者/位置 = 命中点)
# 【主题】倾囊 · 铁灰的钉与迸出的魔屑
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:crit ~ ~ ~ 0.4 0.4 0.4 0.07 14 normal
particle minecraft:enchanted_hit ~ ~ ~ 0.4 0.4 0.4 0.05 12 normal
particle minecraft:dust{color:[0.4,0.72,0.95],scale:1.5} ~ ~ ~ 0.45 0.45 0.45 0.04 14 normal
playsound minecraft:entity.arrow.hit player @a ~ ~ ~ 0.7 1.25
