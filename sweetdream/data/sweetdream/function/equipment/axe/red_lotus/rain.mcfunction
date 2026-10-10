# ============================================================
# sweetdream:equipment/axe/red_lotus/rain —— 超限·红莲: 给 5 格内的敌人挂「流火」
# ------------------------------------------------------------
# 【原文】"若本次共消耗了 6 层及以上「流火」及「夜火」，则使自身 5 格内的敌人
#   每秒都会获得「流火」效果，持续 5 秒。"
# 【谁调用它】cast(施法当刻那一发) / rain_tick(之后每秒一发)
# 【执行者】施法者   【位置】他所在处
# 【为什么走 tag/mark】「流火」是通用标签: 走它才会同时给出护甲 -20%、头顶图标、
#   以及"能被红莲/余烬/热熔再次消耗"这些联动(见 tag/mark_one)。
#   ★ 敌人 = 非玩家活体 —— tag/mark 自己就会把玩家排除掉。
# ============================================================

data modify storage zx:work ic set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic
execute at @s run particle minecraft:flame ~ ~1 ~ 1.6 0.6 1.6 0.05 20 normal
