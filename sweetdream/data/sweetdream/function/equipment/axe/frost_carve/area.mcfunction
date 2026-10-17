# ============================================================
# sweetdream:equipment/axe/frost_carve/area —— 框出"前方 4×3"并打重击伤害
# ------------------------------------------------------------
# 【谁调用它】frost_carve/cast ⑧   【执行者】施法者   【位置】他所在处
# 【怎么框出"前方 4×3"】
#   ★ dx/dy/dz 方盒是世界轴、不跟朝向(坑 157), 4×3 这种长条斜着放会宽深互换;
#     这里用**沿朝向的采样球串**(退汐/盲烛同一套口径):
#       rotated ~ 0(压平俯仰) -> positioned ^ ^ ^1.2 / ^ ^ ^3.2 -> 半径 2.0
#     两球并集 = 前方 0~5.2 段、宽 4 的一条走廊: **宽 4 精确**, 深比原文的 3 略宽松
#     (重击是斧头抡圆了砸, 手感上宁可比 3 格多一点点, 也不要漏掉脚边的怪)。
#   ★ 用 distance 时基准点**不平移到眼睛**: 它量的是到生物**脚底**的距离(坑 157)。
# 【为什么用 zx.frc_hit 认人】apply 要逐只处理"冻 or 解冻", 必须钉住这一锤到底砸到了谁。
#   标签由 cast ⑪ 清掉。
# ============================================================

# 清上一轮残留
tag @e[tag=zx.frc_hit,distance=0..] remove zx.frc_hit

# 采样球 1: 眼前 1.2 格
execute rotated ~ 0 positioned ^ ^ ^1.2 run tag @e[type=!#sweetdream:no_damage,distance=..2.0] add zx.frc_hit
# 采样球 2: 眼前 3.2 格
execute rotated ~ 0 positioned ^ ^ ^3.2 run tag @e[type=!#sweetdream:no_damage,distance=..2.0] add zx.frc_hit

# 重击伤害: 基础攻击力 ×5(值已由 cast ⑥ 算好)
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.frc_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work frc.dmg5
execute at @s run function sweetdream:api/damage

# 表现
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:snowflake ~ ~0.3 ~ 1.6 0.3 1.6 0.04 18 normal
