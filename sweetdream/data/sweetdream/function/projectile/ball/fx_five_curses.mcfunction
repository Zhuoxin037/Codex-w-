# ============================================================
# sweetdream:projectile/ball/fx_five_curses —— 《五世恶咒》的法球拖尾
# ------------------------------------------------------------
# 【谁调用它】ball/tick 第 ④ 步(法球每刻的拖尾) + ball/pop(撞墙时散一下)
# 【主题】世咒 · 暗紫与魂火
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:dust{color:[0.45,0.18,0.62],scale:1.2} ~ ~ ~ 0.12 0.12 0.12 0 7 normal
particle minecraft:soul_fire_flame ~ ~ ~ 0.16 0.16 0.16 0.01 3 normal
particle minecraft:sculk_soul ~ ~ ~ 0.18 0.18 0.18 0.01 2 normal
