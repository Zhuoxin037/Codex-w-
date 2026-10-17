# ============================================================
# sweetdream:equipment/axe/deep_brine/area —— 框出"前方 5×4"并打立即段伤害
# ------------------------------------------------------------
# 【谁调用它】deep_brine/cast ⑧   【执行者】施法者   【位置】他所在处
# 【怎么框出"前方 5×4 格"】
#   ★ dx/dy/dz 判定盒是**世界轴**(东/南/上)延伸的, **不跟随朝向**(RULES 坑 157)。
#     ⇒ "前方 5 格宽 × 4 格深"没法用一行方盒**精确**表达(方盒的 dx/dz 会随朝向互换)。
#   ⇒ 照现役同型先例【烈火, 残躯】"前方 5*3"的口径(flame_brokenbody/cast ⑤):
#       anchored eyes(基准点抬到眼睛) + positioned ^ ^ ^2.0(沿**朝向**推到眼前 2 格,
#       即 4 格深矩形的中心) + 一个 dx=dz=5.0 的方盒。
#     结果 = "眼前 5 格宽 × 5 格深"的一片 —— **宽 5 精确**, 深比原文的 4 略宽松 0.5 格;
#     这是世界轴方盒的固有近似, 与烈火残躯完全同一口径, 全包唯二两处"前方 N×M"。
#   ★ dy=2.6 且基准点比眼睛低 1.3 ⇒ 竖直覆盖身高, 站在地上的怪也判得到。
#     **不许改用 distance**: 它量的是到生物**脚底**的距离(坑 157)。
# 【本轮去重】一只可能同时落进盒里多处(方盒只选一次, 但后续 ⑨ 还要按标签取人)
#   ⇒ 本轮统一用 zx.db_hit 认人, 用完由 cast ⑩ 清掉。
# 【立即段伤害】施法者最大魔力值 ×0.1(值已由 cast ⑥ 算好放在 zx:work db.dmg)。
#   投递走 api/damage —— **执行者仍是玩家**, 击杀归属才对(同崩裂 area 的口径)。
# ============================================================

# 清上一轮(或别人残留)的本轮标记
tag @e[tag=zx.db_hit,distance=0..] remove zx.db_hit

# 框"前方 5×4"(世界轴方盒近似, 口径同 烈火残躯 的"前方 5*3")
execute anchored eyes positioned ^ ^ ^2.0 positioned ~-2.5 ~-1.3 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=2.6,dz=5.0] add zx.db_hit

# 立即段伤害: 最大魔力 ×0.1
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.db_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work db.dmg
execute at @s run function sweetdream:api/damage

# 表现: 重溟的水压冲击
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:splash ~ ~0.8 ~ 2.2 0.6 2.2 0.05 30 normal
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:bubble ~ ~0.5 ~ 2.0 0.5 2.0 0.04 20 normal
