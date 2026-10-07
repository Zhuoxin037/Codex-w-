# ============================================================
# sweetdream:equipment/sword/rebound/area —— 一个采样球(宏 {damage})
# ------------------------------------------------------------
# 【谁调用它】rebound/strike: execute rotated ~ 0 positioned ^ ^ ^N run function ... with storage zx:work rba
# 【执行者】施法者(玩家)  【位置】采样球心(前方 N 格处)
# 【打谁】球内(tag=!zx.rb_hit)的全部生物 —— 同一只本轮只挨一次。
# 【★ 执行者保持玩家 ★】api/damage 靠 @s 是不是玩家决定击杀归属。
# ============================================================

$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=!zx.rb_hit,distance=..1.5]",damage:$(damage)}
function sweetdream:api/damage

# 本轮已打: 把球内的全部生物标上(第二次采样时就不会重复打)
execute as @e[type=!#sweetdream:no_damage,distance=..1.5] run tag @s add zx.rb_hit

# 表现: 前方一道斩击碎光
particle minecraft:enchanted_hit ~ ~1 ~ 1.0 0.8 1.0 0.05 8 normal
