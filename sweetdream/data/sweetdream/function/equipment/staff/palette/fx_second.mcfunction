# ============================================================
# sweetdream:equipment/staff/palette/fx_second —— “色彩”次色粒子(拖尾)
# ------------------------------------------------------------
# 【谁调用它】color_body 第 ⑤ 步(次色拖尾: positioned 到飞行方向"后方偏左")
# 【执行者】色彩 item_display
# 【颜色 = data.zx.pal.c2】—— **只有两个色槽都有颜色时才有值(1/2/3)**,
#   否则 c2 = 0 ⇒ 下面三条 if 全不成立 ⇒ 一个粒子也不生成。
#   ★ 这就是"有两种颜色就加两种拖尾"的另一半: 单色光球只有一条拖尾。
# ============================================================

execute if data entity @s data.zx.pal{c2:1} run particle minecraft:dust{color:[1.0,0.25,0.25],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
execute if data entity @s data.zx.pal{c2:2} run particle minecraft:dust{color:[1.0,0.95,0.3],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
execute if data entity @s data.zx.pal{c2:3} run particle minecraft:dust{color:[0.35,0.6,1.0],scale:1.1} ~ ~ ~ 0.12 0.12 0.12 0.0 3 normal
