# ============================================================
# sweetdream:equipment/sword/deepsea_echo/sfx_ring12 —— "12 格搜索范围"的视觉
# ------------------------------------------------------------
# 【谁调用它】seed(起链那一刻), 执行者与位置都是施法者
# 【画的是什么】脚下一圈半径 12 的蓝色光环, 让玩家一眼看出"我刚搜了多远"。
#   它是"范围"相关的表现, 所以和 3 格球一样用蓝色 dust ——
#   这样全技能的分工就是: 范围=蓝色, 打中=末地烛星点。
#   两圈叠出来更厚实: 内圈 12 个点(半径 12)、外圈 8 个点(半径 12.4)。
#   和 sfx_ring3 一个原理(rotated + positioned ^ ^ ^12), 只是半径放大到 12。
# 【为什么只画地面那一圈】12 格的球壳要上千个点; 一圈贴地的光环既省又够醒目。
# 【开销】只在起链那一下画一次(不像 sfx_ring3 会被反复补画), 所以可以画厚一点。
# ============================================================

execute rotated 0 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 30 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 60 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 90 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 120 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 150 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 180 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 210 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 240 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 270 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 300 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force
execute rotated 330 0 positioned ^ ^ ^12 run particle minecraft:dust{color:[0.30,0.65,1.0],scale:1.5} ~ ~0.3 ~ 0 0 0 0 10 force

execute rotated 0 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 45 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 90 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 135 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 180 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 225 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 270 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
execute rotated 315 0 positioned ^ ^ ^12.4 run particle minecraft:dust{color:[0.45,0.80,1.0],scale:1.8} ~ ~0.3 ~ 0 0 0 0 8 force
