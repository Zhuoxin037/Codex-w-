# ============================================================
# sweetdream:equipment/sword/backflow_tide/area —— 框出"前方 4 格"并打基础段伤害
# ------------------------------------------------------------
# 【谁调用它】backflow_tide/cast ⑧   【执行者】施法者   【位置】他所在处
# 【怎么框出"前方 4 格内"】
#   ★ dx/dy/dz 判定盒是**世界轴**(东/南/上)延伸的, **不跟随朝向**(RULES 坑 157)
#     ⇒ 想表达"沿视线前方 4 格"只能用"把基准点沿朝向前移 + 一个方盒"。
#   ⇒ 照同型现役先例(重溟 deep_brine/area、烈火残躯 flame_brokenbody/cast ⑤):
#       anchored eyes(基准抬到眼睛) -> positioned ^ ^ ^2.0(沿朝向推到眼前 2 格,
#       正好是"眼前 0~4 格"这段的中心) -> dx=dz=4.0 的方盒。
#     于是覆盖 = 眼前深 4 格 × 宽 4 格 —— **宽度与深度都按原文 4 格取**。
#     斜着放技能时方盒是"外接正方形", 边角会多吃一点点, 这是世界轴方盒的固有近似。
#   ★ dy=2.6 且基准点比眼睛低 1.3 ⇒ 竖直覆盖整个人高, 站在地上的怪也判得到。
#     **不许改用 distance**: 它量的是到生物**脚底**的距离(坑 157)。
# 【为什么用 zx.bft_hit 认人】⑨ 还要按"命中者 + 带渊海"再挑一次;
#   用标签钉住"这一刀到底打到了谁", 免得两次 @e 之间目标站的位置变了。
#   标签由 cast ⑩ 统一清掉。
# ============================================================

# 清上一轮残留(重复施放或别人残留都不会串味)
tag @e[tag=zx.bft_hit,distance=0..] remove zx.bft_hit

# 框覆盖范围(世界轴方盒近似, 口径同 重溟 / 烈火残躯)
#   未超限: 眼前 4 格深 × 4 格宽(原版)
#   超限·退汐(2026-10-23 批 K2): 眼前 **6 格**深 × 6 格宽 —— 中心从 2.0 挪到 3.0、边长 4->6
#   ⚠️ #bft_ol 由 cast ③ 设好, 这里只读; 两行互斥, 同一刻只会框一次。
execute if score #bft_ol zx.meta matches 0 anchored eyes positioned ^ ^ ^2.0 positioned ~-2.0 ~-1.3 ~-2.0 run tag @e[type=!#sweetdream:no_damage,dx=4.0,dy=2.6,dz=4.0] add zx.bft_hit
execute if score #bft_ol zx.meta matches 1 anchored eyes positioned ^ ^ ^3.0 positioned ~-3.0 ~-1.3 ~-3.0 run tag @e[type=!#sweetdream:no_damage,dx=6.0,dy=2.6,dz=6.0] add zx.bft_hit

# 基础段伤害: 最大魔力值 ×0.08(值已由 cast ⑥ 算好)
#   ★ 执行者仍是**施法者本人** -> 击杀归属/结算口径都对(同 verdict / 崩裂 area)
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.bft_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work bft.dmg
execute at @s run function sweetdream:api/damage

# 表现: 一道贴着地面扫过去的水刃(超限的另外两道在 cast ⑪)
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:splash ~ ~0.5 ~ 2.0 0.5 2.0 0.05 26 normal
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:bubble ~ ~0.4 ~ 1.8 0.4 1.8 0.03 16 normal
