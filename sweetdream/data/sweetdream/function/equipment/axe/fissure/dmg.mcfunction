# ============================================================
# sweetdream:equipment/axe/fissure/dmg —— 崩裂: 一次"前方 N 格"打击(宏 {damage, ol})
# ------------------------------------------------------------
# 【谁调用它】fissure/cast(⑥)
# 【执行者】施法者; 【位置】他所在处
# 【怎么框出"前方 N 格"】沿朝向每 1.5 格取一个半径 1.5 的球, 串成一条走廊:
#   原版  = 1.0 / 2.5 / 4.0            -> 0~5.5 格长
#   超限  = 再加 5.5 / 7.0             -> 0~8.5 格长
#   ★ 间距 1.5 < 2×半径 1.5 = 3, 球球有重叠、不掐"腰"(同回锋/终末天启的采样口径)。
# 【本轮去重】一次 dmg 里同一只可能落进多个采样球 -> 用 zx.fi_hit 保证每只只挨一次。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.fi_hit,distance=0..] remove zx.fi_hit

execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute rotated ~ 0 positioned ^ ^ ^2.5 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute if data storage zx:work fia{ol:1} rotated ~ 0 positioned ^ ^ ^5.5 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute if data storage zx:work fia{ol:1} rotated ~ 0 positioned ^ ^ ^7.0 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia

tag @e[tag=zx.fi_hit,distance=0..] remove zx.fi_hit
