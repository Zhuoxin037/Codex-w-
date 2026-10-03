# ============================================================
# sweetdream:equipment/sword/deepsea_echo/anim/fx —— 释放动画的粒子层
# ------------------------------------------------------------
# 【谁调用它】anim/tick，执行者与位置都在施法者身上（at @s）
# 【和模型什么关系】下面每一条都挂在**同一个帧号**上（zx.de_cast），
#   所以"水花炸开"永远发生在护手张开的那几帧 —— 不是各跑各的。
#
# 【三段与模型严格对齐】
#   A 蓄力 0-7    外围水汽一层层往身边收（散布半径 3.2 → 1.3）
#   B 爆发 8-15   帧 8 中心炸开（水花 + 亮青白）· 帧 9/11/13 三圈冲击环向外推
#   C 回响 16-31  余波衰减 + 气泡上升；**帧 20 单独加亮** —— 那正是技能第一波
#                 水链落地的那一 tick（cast 起链后 1 秒 = 20 tick），
#                 释放动画和技能本体在视觉上就此接上。
#                 第 2、3 波不归这里管，它们由技能自己的 fx 补画。
#
# 【粒子名】只用这四种，都是原版的：
#   minecraft:dust{color:[r,g,b],scale:s}  唯一能带色的，也是唯一要写 SNBT 的
#     ⚠️ 必须写花括号，老式的位置参数写法会让**整个函数加载失败**（ts_dmg 栽过）
#   minecraft:splash    水花（只有它像"炸开的一捧水"）
#   minecraft:bubble    气泡（上浮）
#   minecraft:nautilus  鹦鹉螺（海洋味，只给帧 20 用）
#
# 【normal 还是 force】核心那两条（水花 / 帧 20 的环）用 force —— 释放的关键帧
#   不该被"粒子效果：最少"直接抹掉；外围的余波、气泡用 normal，别喧宾夺主。
# ============================================================

# ---------- A 蓄力 0-7：水汽向内收 ----------
# ⚠️ 这里必须写 0..1 这种**区间**，不能写 0,1 这种逗号列表。
#   MC 的 `matches` 参数类型是"最小..最大"，**不接受逗号分隔的多值**
#   （能接受逗号列表的是选择器里的 scores={obj=1,2,3}，两回事）。
#   写成 0,1 的后果不是"少播两个粒子"，而是**整个 anim/fx 加载失败** ——
#   2026-10-03 就栽在这上面，日志: Whilst parsing command on line 28 ...
#   ... matches 0<--[HERE]。check.py 第 14 项现在会静态抓这个。
execute if score @s zx.de_cast matches 0..1 run particle minecraft:dust{color:[0.22,0.46,0.86],scale:1.20} ~ ~1.0 ~ 3.2 1.4 3.2 0 10 normal
execute if score @s zx.de_cast matches 2..3 run particle minecraft:dust{color:[0.26,0.52,0.90],scale:1.15} ~ ~1.0 ~ 2.6 1.3 2.6 0 10 normal
execute if score @s zx.de_cast matches 4..5 run particle minecraft:dust{color:[0.30,0.58,0.94],scale:1.10} ~ ~1.0 ~ 1.9 1.1 1.9 0 9 normal
execute if score @s zx.de_cast matches 6..7 run particle minecraft:dust{color:[0.34,0.64,0.98],scale:1.05} ~ ~1.0 ~ 1.3 0.9 1.3 0 7 normal

# ---------- B 爆发 8-15 ----------
execute if score @s zx.de_cast matches 8..10 run particle minecraft:splash ~ ~1.2 ~ 0.7 0.8 0.7 0.50 26 force
execute if score @s zx.de_cast matches 8..10 run particle minecraft:dust{color:[0.74,0.95,1.00],scale:1.90} ~ ~1.2 ~ 0.8 0.9 0.8 0 20 normal
execute if score @s zx.de_cast matches 9 run particle minecraft:dust{color:[0.58,0.88,1.00],scale:1.50} ~ ~1.0 ~ 1.6 0.22 1.6 0 14 normal
execute if score @s zx.de_cast matches 11 run particle minecraft:dust{color:[0.52,0.82,1.00],scale:1.35} ~ ~1.0 ~ 2.5 0.22 2.5 0 14 normal
execute if score @s zx.de_cast matches 13 run particle minecraft:dust{color:[0.46,0.76,1.00],scale:1.25} ~ ~1.0 ~ 3.3 0.22 3.3 0 14 normal
execute if score @s zx.de_cast matches 9..15 run particle minecraft:bubble ~ ~1.6 ~ 0.55 0.9 0.55 0.12 5 normal

# ---------- C 回响 16-31 ----------
# 帧 20 = 技能第一波水链落地：一圈最亮的 + 一小撮鹦鹉螺
execute if score @s zx.de_cast matches 20 run particle minecraft:dust{color:[0.60,0.90,1.00],scale:1.60} ~ ~1.0 ~ 3.9 0.2 3.9 0 20 force
execute if score @s zx.de_cast matches 20 run particle minecraft:nautilus ~ ~1.0 ~ 3.2 0.3 3.2 0.40 12 normal
# 帧 17 / 24：两圈余波，一圈比一圈淡
execute if score @s zx.de_cast matches 17 run particle minecraft:dust{color:[0.44,0.74,1.00],scale:1.25} ~ ~0.9 ~ 3.4 0.2 3.4 0 14 normal
execute if score @s zx.de_cast matches 24 run particle minecraft:dust{color:[0.40,0.70,1.00],scale:1.15} ~ ~0.9 ~ 3.4 0.2 3.4 0 12 normal
# 帧 16-31：气泡持续上浮（把"水还在动"维持到动画结束）
execute if score @s zx.de_cast matches 16..31 run particle minecraft:bubble ~ ~1.2 ~ 0.75 1.0 0.75 0.05 3 normal
