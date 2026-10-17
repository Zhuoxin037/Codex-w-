# ============================================================
# sweetdream:equipment/axe/death_bell/area —— 框出"前方 4 格"并打重击伤害
# ------------------------------------------------------------
# 【谁调用它】death_bell/cast ⑦   【执行者】施法者   【位置】他所在处
# 【怎么框出"前方 4 格内"】
#   ★ dx/dy/dz 方盒是世界轴、不跟朝向(坑 157), 正方形盒斜放会歪;
#     这里用**沿朝向的单个采样球**(照退汐/盲烛同一套口径):
#       rotated ~ 0(压平俯仰) -> positioned ^ ^ ^2(球心落在眼前 2 格) -> distance=..2.0
#     覆盖 = 前方 0~4 格、宽 4 格, 完全跟随朝向。
#   ★ 用 distance 时基准点**不平移到眼睛**: 它量的是到生物**脚底**的距离(坑 157)。
# 【为什么用 zx.dbl_hit 认人】⑧ 还要按"命中者 + 带白昼梦"再挑一次,
#   用标签钉住"这一下到底打到了谁", 免得两次 @e 之间怪跑位。标签由 cast ⑨ 清掉。
# ============================================================

# 清上一轮残留
tag @e[tag=zx.dbl_hit,distance=0..] remove zx.dbl_hit

# 采样球: 眼前 2 格, 半径 2.0
execute rotated ~ 0 positioned ^ ^ ^2 run tag @e[type=!#sweetdream:no_damage,distance=..2.0] add zx.dbl_hit

# 重击伤害: 最大魔力值 ×0.1(值已由 cast ⑥ 算好)
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.dbl_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work dbl.dmg
execute at @s run function sweetdream:api/damage

# 表现
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:crit ~ ~0.3 ~ 1.2 0.3 1.2 0.05 14 normal
