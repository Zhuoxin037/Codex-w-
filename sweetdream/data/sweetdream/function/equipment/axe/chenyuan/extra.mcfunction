# ============================================================
# sweetdream:equipment/axe/chenyuan/extra —— 有增益时额外锁定 3 个生物
# ------------------------------------------------------------
# 【执行者】施法者(位置在他身上)
# 【产出】zx.cy_x(最多 3 只, 6 格内, 排除已经选中的 A / B)
# ============================================================

tag @e[tag=zx.cy_x] remove zx.cy_x
tag @e[tag=zx.cy_pool] remove zx.cy_pool
execute at @s as @e[type=!#sweetdream:no_damage,distance=0.1..6] unless entity @s[tag=zx.cy_a] unless entity @s[tag=zx.cy_b] run tag @s add zx.cy_pool
execute at @s as @e[tag=zx.cy_pool,sort=random,limit=3] run tag @s add zx.cy_x
tag @e[tag=zx.cy_pool] remove zx.cy_pool
