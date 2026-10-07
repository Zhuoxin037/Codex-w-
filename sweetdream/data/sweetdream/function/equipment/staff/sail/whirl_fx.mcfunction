# ============================================================
# sweetdream:equipment/staff/sail/whirl_fx —— 旋风的一帧表现(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一遍; 执行者 = 旋风 marker, at @s 位置在中心)
# 【为什么必须每刻】每秒只画一次的话 20 fps 里有 19 帧是空的 —— 那就是"一团粒子
#   凭空闪一下", 根本看不出在**转**。旋风要转起来必须逐刻推进角度。
# 【角度】zx.sl_a 每刻 +6 度 -> 60 刻(3 秒)转满一圈; 到 360 减回去, 不让它无限涨。
# 【颜色】不在这里定 —— whirl_draw 只摆位置, 到了点上由 whirl_dot 按 zx.sl_m
#   (最近一次附着了哪一种属性)挑颜色: 流火鲜红 / 渊海深蓝 / 白昼梦粉 / 噬心黑。
# ============================================================

# ① 角度推进(每刻 +6 度; 到 360 归零继续)
scoreboard players add @s zx.sl_a 6
execute if score @s zx.sl_a matches 360.. run scoreboard players remove @s zx.sl_a 360

# ② 角度写进 storage, 交给宏函数去拼 rotated
data modify storage zx:work slw set value {a:0}
execute store result storage zx:work slw.a int 1 run scoreboard players get @s zx.sl_a
function sweetdream:equipment/staff/sail/whirl_draw with storage zx:work slw
