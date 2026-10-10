# ============================================================
# sweetdream:equipment/staff/palette/fx_main —— “色彩”主色粒子(球心光晕 + 拖尾共用)
# ------------------------------------------------------------
# 【谁调用它】color_body 第 ⑤ 步(共两处, 只是执行位置不同):
#   ① 球心光晕 : 直接执行   -> `~ ~ ~` = 光球中心
#   ② 主色拖尾 : positioned 到飞行方向"后方偏右" -> `~ ~ ~` = 拖尾发射点
# 【执行者】色彩 item_display
# 【颜色 = data.zx.pal.c】1 红 / 2 黄 / 3 蓝 / 0(无色)中性白。
#   ★ c = 主色: 两个色槽都有颜色时取"旧槽" c1, 否则取唯一的那个色。
#     另一只颜色走 fx_second(次色 c2) —— 单色光球只有这一条拖尾。
# ============================================================

execute if data entity @s data.zx.pal{c:1} run particle minecraft:dust{color:[1.0,0.25,0.25],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
execute if data entity @s data.zx.pal{c:2} run particle minecraft:dust{color:[1.0,0.95,0.3],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
execute if data entity @s data.zx.pal{c:3} run particle minecraft:dust{color:[0.35,0.6,1.0],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
execute if data entity @s data.zx.pal{c:0} run particle minecraft:dust{color:[0.85,0.85,0.9],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
