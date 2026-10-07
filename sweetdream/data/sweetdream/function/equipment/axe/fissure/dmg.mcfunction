# ============================================================
# sweetdream:equipment/axe/fissure/dmg —— 崩裂: 一次"前方 5 格"打击(宏 {damage})
# ------------------------------------------------------------
# 【谁调用它】fissure/cast(⑥)
# 【执行者】施法者; 【位置】他所在处
# 【怎么框出"前方 5 格"】沿朝向在 1.0 / 2.5 / 4.0 格处各取一个半径 1.5 的球,
#   三球合起来就是一条 0~5.5 格长、宽 ±1.5(3 格)的走廊。
#   ★ 间距 1.5 < 2×半径 1.5 = 3, 三球有重叠、不掐"腰"(同回锋/终末天启的采样口径)。
# 【本轮去重】一次 dmg 里同一只可能落进多个采样球 -> 用 zx.fi_hit 保证每只只挨一次。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.fi_hit,distance=0..] remove zx.fi_hit

execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute rotated ~ 0 positioned ^ ^ ^2.5 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/axe/fissure/area with storage zx:work fia

tag @e[tag=zx.fi_hit,distance=0..] remove zx.fi_hit
