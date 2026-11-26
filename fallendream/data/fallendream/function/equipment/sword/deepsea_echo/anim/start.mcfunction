# 沿用 cast 施法成立后的原入口；只开始视觉动画，不改变技能数值或连锁计时。
# 水刃 floats[0] 待机帧，floats[1] 施法帧；48 表示恢复待机。
scoreboard players set @s zx.de_wave 0
scoreboard players set @s zx.de_cast 0
tag @s add zx.de_cast
