# ============================================================
# sweetdream:equipment/sword/rebound/strike —— 一次"前方 3×5"打击
# ------------------------------------------------------------
# 【谁调用它】rebound/cast(基础一次 + 每层再调一次)
# 【执行者】施法者; 【位置】他所在处
# 【怎么框出"前方 3 格宽 × 5 格长"】用 3 个采样点:
#   沿朝向分别在前方 1.0 / 2.5 / 4.0 格处各取一个半径 1.5 的球,
#   三球合起来就是一条 0~5.5 格长、宽 ±1.5(3 格)的走廊。
#   ★ 间距 1.5 < 2×半径 1.5 = 3, 三球有重叠、不掐"腰"(和终末天启 9 球采样同一个道理)。
# 【本轮内去重】同一次 strike 里, 一只生物可能落进多个采样球 -> 用 zx.rb_hit 保证
#   本轮每只只挨一次。下一层再 strike 时先把标记清掉, 于是"每层一次"照样成立。
# 【为什么清标记要带 distance=0..】裸 @e 跨维度; 带上位置参数才是"当前维度里的这些"。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.rb_hit,distance=0..] remove zx.rb_hit

# 3 个采样点(沿朝向, 俯仰归零避免打到脚前)
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/sword/rebound/area with storage zx:work rba
execute rotated ~ 0 positioned ^ ^ ^2.5 run function sweetdream:equipment/sword/rebound/area with storage zx:work rba
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/sword/rebound/area with storage zx:work rba

# 收尾清标记, 不留残余
tag @e[tag=zx.rb_hit,distance=0..] remove zx.rb_hit
