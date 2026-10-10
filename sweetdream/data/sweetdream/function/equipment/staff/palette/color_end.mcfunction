# ============================================================
# sweetdream:equipment/staff/palette/color_end —— “色彩”自毁
# ------------------------------------------------------------
# 【谁调用它】color_body(寿命到 / 出界) 与 color_hit(打满阀值)
# 【执行者/位置】色彩 item_display
# 【收尾】清掉挑选标记(可能还有残留) + 粒子音效 + kill @s
# ============================================================

tag @e[tag=zx.pal_t,distance=0..] remove zx.pal_t
tag @e[tag=zx.pal_c,distance=0..] remove zx.pal_c
particle minecraft:end_rod ~ ~ ~ 0.25 0.25 0.25 0.06 16 normal
particle minecraft:effect ~ ~ ~ 0.3 0.3 0.3 0.05 10 normal
playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.6 1.6
kill @s
