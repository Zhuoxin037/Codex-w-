# ============================================================
# sweetdream:equipment/staff/sail/whirl_pulse_fx —— 脉冲那一下的"吸力圈"
# ------------------------------------------------------------
# 【谁调用它】whirl_pulse 第 ③ 步(每 3 秒一次); 【执行者/位置】旋风 marker
# 【画什么】半径 5 的一圈 8 颗带色尘 —— 把"吸引 5 格内生物"这个**范围**画出来,
#   让人一眼看出这一拍生效了。角度写死(不跟着 zx.sl_a 转), 是个稳定的圈。
# 【颜色】同 whirl_draw: 交给 whirl_dot 按 zx.sl_m 分支(本拍刚附着的那一种)。
# ============================================================

execute rotated ~0 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~45 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~90 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~135 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~180 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~225 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~270 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
execute rotated ~315 0 positioned ^5.0 ^0.15 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
