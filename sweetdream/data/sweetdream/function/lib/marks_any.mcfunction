# ============================================================
# sweetdream:lib/marks_any —— 从一批生物里挑出"带任意一个通用标签"的
# ------------------------------------------------------------
# 【宏参数】zx:work ma {target}   【产出】给挑中的生物挂 zx.marked
# 【状态来源】原生 Tags 中的 zx.status.*，与通用标签接口和击杀进度保持一致。
# 【为什么开头先清一遍】zx.marked 就是"返回值", 用之前必须保证干净。
# ============================================================

tag @e[tag=zx.marked] remove zx.marked
$execute as $(target) if entity @s[tag=zx.status.yuanhai] run tag @s add zx.marked
$execute as $(target) if entity @s[tag=zx.status.liuhuo] run tag @s add zx.marked
$execute as $(target) if entity @s[tag=zx.status.yehuo] run tag @s add zx.marked
$execute as $(target) if entity @s[tag=zx.status.shixin] run tag @s add zx.marked
$execute as $(target) if entity @s[tag=zx.status.dream] run tag @s add zx.marked
