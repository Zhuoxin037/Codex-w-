# ============================================================
# sweetdream:equipment/staff/sail/whirl_dot —— 在"当前位置"点一颗带色的尘
# ------------------------------------------------------------
# 【谁调用它】whirl_draw(每刻画螺旋的那 15 个点) / whirl_pulse_fx(脉冲圈那 8 个点)
# 【位置/执行者】调用方已经用 `rotated … positioned ^ ^ ^` 把坐标摆好了,
#   而 `run function` **会带着执行者与坐标一起过去** —— 所以这里 @s 仍是旋风
#   marker, ~ ~ ~ 就是调用方算出来的那一个点。
# 【★ 为什么颜色要单独拆一层 ★】1.21.5 的 dust 颜色写在花括号里
#   (`dust{color:[r,g,b],scale:s}`), 而**花括号不能进 `set value` 的字符串**
#   (规则 64: 会让整个函数加载失败)。所以颜色没法当宏参数传 ——
#   只能把"点在哪"交给宏, 把"点成什么颜色"留在这个小函数里按 zx.sl_m 分支。
#   于是几何只写一份(whirl_draw 里 18 行), 颜色只写一份(这里 5 行)。
# 【颜色口径(用户 2026-10-08)】
#   zx.sl_m: 0 素白风 / 1 渊海=深蓝 / 2 流火=鲜红 / 3 白昼梦=粉色 / 4 噬心=黑色
# ============================================================

execute if score @s zx.sl_m matches 0 run particle minecraft:dust{color:[0.88,0.92,1.0],scale:1.2} ~ ~ ~ 0.05 0.05 0.05 0.0 2 normal
execute if score @s zx.sl_m matches 1 run particle minecraft:dust{color:[0.06,0.18,0.62],scale:1.5} ~ ~ ~ 0.05 0.05 0.05 0.0 2 normal
execute if score @s zx.sl_m matches 2 run particle minecraft:dust{color:[1.0,0.14,0.08],scale:1.5} ~ ~ ~ 0.05 0.05 0.05 0.0 2 normal
execute if score @s zx.sl_m matches 3 run particle minecraft:dust{color:[1.0,0.48,0.78],scale:1.5} ~ ~ ~ 0.05 0.05 0.05 0.0 2 normal
execute if score @s zx.sl_m matches 4 run particle minecraft:dust{color:[0.04,0.04,0.06],scale:1.9} ~ ~ ~ 0.05 0.05 0.05 0.0 2 normal
