# ============================================================
# sweetdream:equipment/sword/remelt/melt —— 把一只生物的护甲乘区压到 0
# ------------------------------------------------------------
# 【执行者】被融甲的生物
# 【怎么做到"护甲值归 0"而不去读它原本有多少甲】
#   armor 属性的乘区 add_multiplied_base -1.0 -> 最终值 = 原值 ×(1 + (-1)) = 0。
#   这样"归零"和"还原"各是一句话, 不用备份原值(和 lib/freeze 冻速度用的是同一招)。
# 【同 id 先 remove 再 add】重复融甲时值会继续叠加成负数, 先摘干净再加。
# 【10 秒怎么记】写在自己身上的 zx.rm_t = 10 秒, 由 remelt/second 每秒扣, 到点调 melt_end。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:remelt
attribute @s minecraft:armor modifier add sweetdream:remelt -1.0 add_multiplied_base
scoreboard players set @s zx.rm_t 10
tag @s add zx.rm_melt
