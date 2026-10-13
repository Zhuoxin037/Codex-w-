# ============================================================
# sweetdream:equipment/sword/tidemark/area —— 一个采样球(宏 {dmg})
# ------------------------------------------------------------
# 【谁调用它】tidemark/strike: execute rotated ~ 0 positioned ^ ^ ^N run function ... with storage zx:work tm
# 【执行者】施法者(玩家)  【位置】采样球心(前方 N 格处)
# 【打谁】球内(tag=!zx.tm_hit)的全部生物 —— 同一只本轮只挨一次。
# 【★ 执行者保持玩家 ★】api/damage 靠 @s 是不是玩家决定击杀归属。
# ============================================================

$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=!zx.tm_hit,distance=..1.0]",damage:$(dmg)}
function sweetdream:api/damage

# 本轮已打: 把球内的全部生物标上(第二个采样点就不会重复打; cast ⑧ 还要用它挑随机者)
execute as @e[type=!#sweetdream:no_damage,distance=..1.0] run tag @s add zx.tm_hit

# 表现: 一圈水色涟漪
particle minecraft:splash ~ ~0.6 ~ 1.0 0.4 1.0 0.02 12 normal
