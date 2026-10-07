# 宏: 在半径 5 处画一个点($(a) = 绝对角度)。
#   ★ 两层 ★ 贴地那层(y+0.05)是玩家判断"我在不在圈里"的边界线,
#            抬高的那层(y+0.9)让这个圈在草丛/坑洼地形里也不会整段被地面吃掉。
#   【为什么改掉旧版】旧版只有一层 y+0.2 的小尘点 + portal。portal 那类是
#     "到处飘"的, 混进来反而糊; 玩家的反馈是"领域不明显" —— 站在圈里完全看不出
#     自己在圈内, 而攻击计数 / 特殊技能窗口全都判这一条边界。
$execute at @s rotated ~$(a) 0 positioned ^5.0 ^0.05 ^0 run particle minecraft:dust{color:[0.85,0.62,0.95],scale:1.8} ~ ~ ~ 0 0 0 0.0 1 normal
$execute at @s rotated ~$(a) 0 positioned ^5.0 ^0.9 ^0 run particle minecraft:dust{color:[0.95,0.80,1.0],scale:1.3} ~ ~ ~ 0 0 0 0.0 1 normal
