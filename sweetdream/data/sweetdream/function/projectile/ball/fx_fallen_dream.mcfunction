# ============================================================
# sweetdream:projectile/ball/fx_fallen_dream —— 《堕梦》的法球拖尾
# ------------------------------------------------------------
# 【谁调用它】ball/tick 第 ④ 步(法球每刻的拖尾) + ball/pop(撞墙时散一下)
# 【主题】白昼梦 · 熄灭的灰烬
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:ash ~ ~ ~ 0.13 0.13 0.13 0.01 6 normal
particle minecraft:dust{color:[0.62,0.6,0.65],scale:1.2} ~ ~ ~ 0.12 0.12 0.12 0 5 normal
particle minecraft:white_smoke ~ ~ ~ 0.2 0.2 0.2 0.01 2 normal
