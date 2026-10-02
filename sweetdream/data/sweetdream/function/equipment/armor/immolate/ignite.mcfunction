# ============================================================
# sweetdream:equipment/armor/immolate/ignite —— 给单只生物点火并接力给余烬
# ------------------------------------------------------------
# 【执行者】被焚舟选中的生物   【执行位置】生物脚下
# 【① 只延长不缩短】目标已经在烧, 而且剩余时间比 10 tick 更长时,
#   直接 data merge Fire:10s 会把一段长燃烧砍成 10 tick —— 反而帮倒忙。
#   所以先读一次, 不足 10 tick 才补到 10 tick。
# 【② 打 zx.em_burn】余烬的边沿标记。见 burn_ray 顶部注释:
#   0.5 秒的火短于余烬 1 秒的采样周期, 不打标记就会漏触发。
#   打了之后, 余烬下一秒的处理是幂等的 —— 火还没灭就 return, 灭了才结流火。
# ============================================================

scoreboard players set #im_f zx.meta 0
execute store result score #im_f zx.meta run data get entity @s Fire
execute unless score #im_f zx.meta matches 10.. run data merge entity @s {Fire:10s}

tag @s add zx.em_burn

particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal
