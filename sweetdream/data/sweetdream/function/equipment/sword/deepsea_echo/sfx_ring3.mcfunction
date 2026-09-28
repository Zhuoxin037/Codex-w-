# ============================================================
# sweetdream:equipment/sword/deepsea_echo/sfx_ring3 —— "3 格范围"的视觉
# ------------------------------------------------------------
# 【谁调用它】hit_area(每个"源"各调一次), 执行者与位置都在那个源身上
# 【用什么粒子】只用 minecraft:dust —— 它是原版**唯一能带颜色**的粒子,
#   想调成什么颜色就调什么颜色(现在是海水蓝)。
#   ⚠️ dust 的参数必须写成 **SNBT**, 不是把数字直接跟在名字后面:
#     particle dust{color:[0.0,0.0,1.0],scale:1.0} <坐标> <散布> <速度> <数量> force
#   写错的话不在加载时报错、而在运行时报错, 会把后面所有命令全截断。
#   scale 是粒子大小, 1.0 比较小, 这里用 1.4 让它看得清。
# 【为什么这里没有海味的鹦鹉螺/气泡】这一份专门负责"范围" —— 用蓝色是为了
#   和"打中了"(鹦鹉螺/气泡/水花)区分开: 蓝=范围, 海味=命中。
# 【画的是什么】
#   · 球内铺满蓝色粒子       —— 一次命令撒一整团
#   · 中心一柱升起的蓝       —— 从脚下冲到头顶
#   · 外圈 12 个采样连成半径 3 的光环 —— 把边界标出来
# 【怎么画"圆"】粒子只能在一个盒子里随机撒, 直接撒是方的。
#   所以绕源转一圈, 每个角度在距离 3 的位置放一个点:
#     execute rotated <yaw> 0 positioned ^ ^ ^3 run particle ...
#   rotated 改朝向 -> positioned ^ ^ ^3 沿那个朝向走 3 格 -> 正好落在圆周上。
# 【开销】每秒会被补画 4 次(见 fx), 所以数量压得克制: 每次约 15 条命令;
#   补画时最多画 8 个源(fx_go 里的 limit=8)。
# ============================================================

# 球内: 一整团蓝色粒子
particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 3.0 3.0 3.0 0 55 force

# 中心: 一柱升起的蓝
particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.6} ~ ~0.2 ~ 0.5 1.4 0.5 0 20 force

# 外圈: 12 个采样点连成半径 3 的光环
execute rotated 0 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 30 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 60 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 90 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 120 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 150 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 180 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 210 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 240 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 270 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 300 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
execute rotated 330 0 positioned ^ ^ ^3 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 3 force
