# ============================================================
# sweetdream:equipment/sword/deepsea_echo/sfx_ring4 —— 半径 4 的范围环(超限版)
# ------------------------------------------------------------
# 【和 sfx_ring3 的关系】完全照抄, 只把半径 3 换成 4 —— 超限·深海的回响的
#   伤害范围是 4 格(基础版 3 格), 表现必须跟着改, 否则玩家按看到的圈躲伤害
#   会躲错。
#   ★ 为什么复制一份而不是参数化: 12 个采样点的角度是写死的, 参数化要上宏;
#     两个文件各自 14 行、一眼能读完, 比多一层宏好维护(见 hit_area ①.5 的分流)。
# ============================================================

particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 4.0 4.0 4.0 0 24 normal

particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.6} ~ ~0.2 ~ 0.5 1.4 0.5 0 10 normal

execute rotated 0 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 30 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 60 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 90 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 120 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 150 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 180 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 210 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 240 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 270 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 300 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
execute rotated 330 0 positioned ^ ^ ^4 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.4} ~ ~1 ~ 0 0 0 0 2 normal
