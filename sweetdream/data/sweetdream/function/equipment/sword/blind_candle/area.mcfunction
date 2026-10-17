# ============================================================
# sweetdream:equipment/sword/blind_candle/area —— 框出"前方 4×5"并打范围伤害
# ------------------------------------------------------------
# 【谁调用它】blind_candle/cast ⑦   【执行者】施法者   【位置】他所在处
# 【怎么框出"前方 4×5"】
#   ★ dx/dy/dz 判定盒是**世界轴**(东/南/上)延伸的、**不跟随朝向**(RULES 坑 157)
#     ⇒ 宽 4 × 深 5 这种"长条"方盒一旦斜着放就会宽深互换, 比正方盒更难看。
#   ⇒ 改用**沿朝向的采样球串**(现役同型先例: tidemark/retreat 用 ^ ^ ^N 的球做走廊):
#        rotated ~ 0(压平俯仰, 只保留水平前方)
#        positioned ^ ^ ^1.5 / ^ ^ ^3.5 各取一个半径 2.0 的球。
#     两球并集 = 前方 0~6 段、宽 4 的一条走廊: **宽 4 精确**, 深度比原文的 5 略宽松
#     (前缘多出约 0.5 格)。好处是完全跟随朝向, 转身放技能不会歪。
#   ★ 用 distance 时基准点**不平移到眼睛**: distance 量的是到生物**脚底**的距离
#     (坑 157), 球心留在脚底水平上, 判定最稳。
# 【为什么用 zx.bcd_hit 认人】⑧ 还要按"命中者 + 带夜火"再挑一次;
#   用标签钉住"这一次到底打到了谁", 免得两次 @e 之间怪跑位。标签由 cast ⑨ 清掉。
# ============================================================

# 清上一轮残留
tag @e[tag=zx.bcd_hit,distance=0..] remove zx.bcd_hit

# 采样球 1: 眼前 1.5 格(覆盖 0 ~ 3.5)
execute rotated ~ 0 positioned ^ ^ ^1.5 run tag @e[type=!#sweetdream:no_damage,distance=..2.0] add zx.bcd_hit
# 采样球 2: 眼前 3.5 格(覆盖 1.5 ~ 5.5)
execute rotated ~ 0 positioned ^ ^ ^3.5 run tag @e[type=!#sweetdream:no_damage,distance=..2.0] add zx.bcd_hit

# 范围伤害: 最大魔力值 ×0.14(值已由 cast ⑥ 算好)
#   ★ 执行者仍是**施法者本人** -> 击杀归属/结算口径都对
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.bcd_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work bcd.dmg
execute at @s run function sweetdream:api/damage

# 表现: 贴地扫过的火舌
execute rotated ~ 0 positioned ^ ^ ^1.5 run particle minecraft:flame ~ ~0.3 ~ 1.4 0.3 1.4 0.02 16 normal
execute rotated ~ 0 positioned ^ ^ ^3.5 run particle minecraft:flame ~ ~0.3 ~ 1.4 0.3 1.4 0.02 16 normal
