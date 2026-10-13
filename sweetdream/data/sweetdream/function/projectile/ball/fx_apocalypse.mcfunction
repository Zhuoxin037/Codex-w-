# ============================================================
# sweetdream:projectile/ball/fx_apocalypse —— 《启示录》的法球拖尾
# ------------------------------------------------------------
# 【谁调用它】ball/tick 第 ④ 步(法球每刻的拖尾) + ball/pop(撞墙时散一下)
# 【主题】灾示 · 金符文与书页蜡屑
# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。
# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),
#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,
#   并且会把后面所有命令一起截断。
# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。
# ============================================================

particle minecraft:dust{color:[1.0,0.82,0.35],scale:1.2} ~ ~ ~ 0.12 0.12 0.12 0 8 normal
particle minecraft:enchant ~ ~ ~ 0.25 0.25 0.25 0.02 2 normal
particle minecraft:wax_on ~ ~ ~ 0.18 0.18 0.18 0.01 3 normal
