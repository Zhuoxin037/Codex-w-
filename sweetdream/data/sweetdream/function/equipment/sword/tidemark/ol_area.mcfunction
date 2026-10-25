# ============================================================
# sweetdream:equipment/sword/tidemark/ol_area —— 超限·潮痕的一个采样球(宏 {dmg})
# ------------------------------------------------------------
# 【谁调用它】tidemark/ol_strike(9 次, 每次球心不同)
# 【执行者】施法者(玩家)  【位置】球心
# 【半径 1.05 与 ol_strike 的采样间距配套】横向 ±1.5 配 1.05 -> -2.55~2.55(5 宽);
#   纵向 1.0/2.0/3.0 配 1.05 -> -0.05~4.05(4 长)。改一处要连另一处一起改。
# 【★ 打人半径 == 打标记半径 ★】都是 1.05 —— 查询半径和清理半径不一致是"法球
#   命中后不消失"那类事故的根(见 MEMORY 里"计分项铁律"第一条)。
# ============================================================

$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=!zx.tm_hit,distance=..1.05]",damage:$(dmg)}
function sweetdream:api/damage

execute as @e[type=!#sweetdream:no_damage,distance=..1.05] run tag @s add zx.tm_hit

particle minecraft:splash ~ ~0.6 ~ 1.05 0.5 1.05 0.02 7 normal
