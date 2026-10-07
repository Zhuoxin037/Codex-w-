# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_count —— 数"这只身上有几个通用效果"
# ------------------------------------------------------------
# 【执行者】@s = 那只(刚被杀的)生物   【出参】#dd_x zx.meta ∈ 0..5
# 【用途】超限版的"额外使自身获得 100×X 魔力值上限（X 为该生物所有的效果数量）"。
# 【为什么数的是原生 Tags】通用标签就是打在 Tags 里的 zx.status.*, 与
#   lib/marks_any 同源; 那边是"挑出带**任意一个**的", 这里是"数出有几个"。
# ============================================================

scoreboard players set #dd_x zx.meta 0
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players add #dd_x zx.meta 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players add #dd_x zx.meta 1
execute if entity @s[tag=zx.status.yehuo] run scoreboard players add #dd_x zx.meta 1
execute if entity @s[tag=zx.status.shixin] run scoreboard players add #dd_x zx.meta 1
execute if entity @s[tag=zx.status.dream] run scoreboard players add #dd_x zx.meta 1
